package com.ericbeaubrun.presencesys.infrastructure.persistence;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PersonRepository personRepository;
    private final StudentRepository studentRepository;
    private final CourseRepository courseRepository;
    private final AttendanceRepository attendanceRepository;
    private final Random random = new Random();

    public DataInitializer(UserRepository userRepository, PersonRepository personRepository,
                           StudentRepository studentRepository, CourseRepository courseRepository,
                           AttendanceRepository attendanceRepository) {
        this.userRepository = userRepository;
        this.personRepository = personRepository;
        this.studentRepository = studentRepository;
        this.courseRepository = courseRepository;
        this.attendanceRepository = attendanceRepository;
    }

    @Override
    public void run(String... args) throws Exception {
        if (userRepository.count() > 0) {
            System.out.println("=> Base de données déjà initialisée. Passage.");
            return;
        }

        System.out.println("=> Début de la génération du dataset de test...");

        userRepository.save(new UserEntity("U00000001", "admin", "$2a$10$vI8aWBnW3fID.ZQ4/o1GVOq1EXDBAjPZ65tUf5d96fWlS.N0oV87C", "ROLE_ADMIN")); // mdp: admin
        userRepository.save(new UserEntity("U00000002", "secretaire", "$2a$10$vI8aWBnW3fID.ZQ4/o1GVOq1EXDBAjPZ65tUf5d96fWlS.N0oV87C", "ROLE_USER"));

        List<StudentEntity> students = new ArrayList<>();
        String[] noms = {"Dupont", "Durand", "Martin", "Bernard", "Dubois", "Thomas", "Robert", "Richard", "Petit", "Lucas", "Garcia", "Silva", "Meunier", "Barbier", "Arnaud"};
        String[] prenoms = {"Jean", "Marie", "Pierre", "Lucas", "Emma", "Chloé", "Thomas", "Julie", "Hugo", "Lea", "Antoine", "Sarah", "Clara", "Mathieu", "David"};

        for (int i = 1; i <= 15; i++) {
            String idStr = String.format("%09d", i); // Exemple: "000000001"
            String cardStr = String.format("%08d", 99000 + i); // Exemple: "00099001"

            PersonEntity person = new PersonEntity(idStr, noms[i - 1], prenoms[i - 1], prenoms[i - 1].toLowerCase() + "." + noms[i - 1].toLowerCase() + "@univ.fr");
            personRepository.save(person);

            StudentEntity student = new StudentEntity(idStr, cardStr, "CLASS_INF");
            students.add(studentRepository.save(student));
        }

        List<CourseEntity> courses = new ArrayList<>();
        LocalDate startDate = LocalDate.now().minusWeeks(3);
        int courseCounter = 1;

        for (int day = 0; day < 21; day++) {
            LocalDate currentDay = startDate.plusDays(day);

            if (currentDay.getDayOfWeek().getValue() <= 5) {

                String idMatin = String.format("C%08d", courseCounter++);
                CourseEntity coursMatin = new CourseEntity(idMatin, currentDay, LocalTime.of(9, 0), LocalTime.of(12, 0), "SALLE_101");
                courses.add(courseRepository.save(coursMatin));

                String idAprem = String.format("C%08d", courseCounter++);
                CourseEntity coursAprem = new CourseEntity(idAprem, currentDay, LocalTime.of(14, 0), LocalTime.of(17, 0), "SALLE_202");
                courses.add(courseRepository.save(coursAprem));
            }
        }

        for (CourseEntity course : courses) {
            LocalTime limitTime = course.getStartTime();

            for (StudentEntity student : students) {
                AttendanceEntity attendance = new AttendanceEntity();
                attendance.setStudentId(student.getId());
                attendance.setCourseId(course.getId());

                int rng = random.nextInt(100);

                if (rng < 85) {
                    attendance.setStatus("present");
                    attendance.setJustification(null);

                    if (random.nextInt(10) == 0) {
                        attendance.setArrivalTime(limitTime.plusMinutes(random.nextInt(25) + 1));
                    } else {
                        attendance.setArrivalTime(limitTime.minusMinutes(random.nextInt(15)));
                    }

                } else if (rng < 93) {
                    attendance.setStatus("absent justifie");
                    attendance.setJustification("Certificat médical ou motif familial");
                    attendance.setArrivalTime(null);
                } else {
                    attendance.setStatus("absent");
                    attendance.setJustification(null);
                    attendance.setArrivalTime(null);
                }

                attendanceRepository.save(attendance);
            }
        }

        System.out.println("=> Dataset généré avec succès ! (15 étudiants, " + courses.size() + " cours, et " + (courses.size() * 15) + " lignes d'émargement)");
    }
}