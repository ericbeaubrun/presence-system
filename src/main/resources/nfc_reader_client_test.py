import sys
import json
import requests
from smartcard.System import readers
from smartcard.util import toHexString

SERVER_URL = "http://localhost:8080/api/v1/attendances"
READER_ID = "L0001"

def get_acr122u_reader():
    r = readers()
    for reader in r:
        if "ACR122" in str(reader):
            return reader
    return None

def extract_uid(connection):
    GET_UID_APDU = [0xFF, 0xCA, 0x00, 0x00, 0x00]
    data, sw1, sw2 = connection.transmit(GET_UID_APDU)
    if sw1 == 0x90 and sw2 == 0x00:
        hex_uid = toHexString(data).replace(" ", "").lower()
        if len(hex_uid) > 8:
            hex_uid = hex_uid[:8]
        elif len(hex_uid) < 8:
            hex_uid = hex_uid.zfill(8)
        return hex_uid
    return None

def send_attendance(card_id):
    payload = {
        "readerId": READER_ID,
        "cardId": card_id
    }
    headers = {
        "Content-Type": "application/json"
    }
    try:
        response = requests.post(SERVER_URL, data=json.dumps(payload), headers=headers, timeout=5)
        print(f"[{response.status_code}] {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"[ERREUR] Connexion serveur impossible : {e}")

def main():
    reader = get_acr122u_reader()
    if reader is None:
        print("[ERREUR] Lecteur ACR122U introuvable.")
        sys.exit(1)

    print(f"Lecteur actif : {reader}")
    print("En attente d'un badge NFC...")

    last_uid = None

    while True:
        try:
            connection = reader.createConnection()
            connection.connect()

            uid = extract_uid(connection)
            if uid and uid != last_uid:
                print(f"Badge détecté - UID: {uid}")
                send_attendance(uid)
                last_uid = uid

        except Exception:
            last_uid = None

        try:
            import time
            time.sleep(0.5)
        except KeyboardInterrupt:
            print("\nArrêt du client léger.")
            break

if __name__ == "__main__":
    main()