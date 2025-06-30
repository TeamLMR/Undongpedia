package com.up.spring.reservation.controller;

import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.CourseSchedule;
import com.up.spring.course.model.service.CourseService;
import com.up.spring.course.model.service.CourseScheduleService;
import com.up.spring.reservation.service.ReservationRedisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.sql.Date;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/reservation")
@RequiredArgsConstructor
@Slf4j
public class ReservationController {

    private final CourseService courseService;
    private final CourseScheduleService courseScheduleService;
    private final ReservationRedisService reservationRedisService;
    private final RedisTemplate<String, Object> redisTemplate;

    @GetMapping("/{courseSeq}")
    public String reservationPage(@PathVariable Long courseSeq, Model model) {
        try {
            // 실제 DB에서 강의 정보 조회
            Course course = courseService.searchById(courseSeq);

            if (course == null) {
                // 강의가 없는 경우 에러 페이지로 리다이렉트하거나 404 처리
                model.addAttribute("errorMessage", "존재하지 않는 강의입니다.");
                return "redirect:/";
                // TODO : 일단 인덱스로 리다이렉트 했어요~~~ LIST 만들면 msg 띄우고 거기로 보낼예정

            }

            model.addAttribute("course", course);
            model.addAttribute("today", LocalDate.now().toString());

            log.info("강의 정보 조회 성공 - courseSeq: {}, title: {}", courseSeq, course.getCourseTitle());

        } catch (Exception e) {
            log.error("강의 정보 조회 중 오류 발생 - courseSeq: {}", courseSeq, e);

            // 에러 발생 시 더미 데이터 사용 (임시 처리)
            Map<String, Object> dummyCourse = new HashMap<>();
            dummyCourse.put("courseSeq", courseSeq);
            dummyCourse.put("courseTitle", "강의 정보 로딩 실패");
            dummyCourse.put("courseContent", "강의 정보를 불러오는 중 문제가 발생했습니다.");
            dummyCourse.put("coursePrice", 0);
            dummyCourse.put("courseDiscount", 0);
            dummyCourse.put("courseType", "OFF");
            dummyCourse.put("courseDifficult", 1);
            dummyCourse.put("courseTarget", "정보 없음");
            dummyCourse.put("coursePreparation", "정보 없음");

            model.addAttribute("course", dummyCourse);
            model.addAttribute("today", LocalDate.now().toString());
            model.addAttribute("errorMessage", "강의 정보 로딩 중 오류가 발생했습니다.");
        }

        return "reservation/course-reservation";
    }

    @RequestMapping("/test")
    public String test(Model model) {
        // 테스트용 더미 데이터
        Map<String, Object> course = new HashMap<>();
        course.put("courseSeq", 1L);
        course.put("courseTitle", "테스트 강의");
        course.put("courseContent", "테스트용 강의입니다.");
        course.put("coursePrice", 50000);
        course.put("courseDiscount", 10);
        course.put("courseType", "OFF");
        course.put("courseDifficult", 2);
        course.put("courseTarget", "테스트 대상");
        course.put("coursePreparation", "테스트 준비물");

        model.addAttribute("course", course);
        model.addAttribute("today", LocalDate.now().toString());

        return "reservation/course-reservation";
    }

    /**
     * 실시간 대기열 모니터링 페이지
     */
    @GetMapping("/monitor")
    public String queueMonitorPage() {
        return "reservation/queue-monitor";
    }


    @GetMapping("/available-dates")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getAvailableDates(
            @RequestParam Long courseSeq) {

        try {
            // 실제 DB에서 CourseSchedule 조회
            List<CourseSchedule> schedules = courseScheduleService.searchScheduleByCourseSeq(courseSeq);

            // 날짜별로 그룹핑하여 예약 가능한 날짜 정보 생성
            Map<LocalDate, List<CourseSchedule>> schedulesByDate = schedules.stream()
                    .filter(schedule -> schedule.getCourseDate().toLocalDate().isAfter(LocalDate.now().minusDays(1))) // 오늘 이후 날짜만
                    .collect(Collectors.groupingBy(schedule -> schedule.getCourseDate().toLocalDate()));

            List<Map<String, Object>> availableDates = new ArrayList<>();

            for (Map.Entry<LocalDate, List<CourseSchedule>> entry : schedulesByDate.entrySet()) {
                LocalDate date = entry.getKey();
                List<CourseSchedule> daySchedules = entry.getValue();

                int totalSlots = daySchedules.size();
                int availableSlots = (int) daySchedules.stream()
                        .filter(s -> s.getBookedSeats() < s.getCourseCapacity())
                        .count();

                if (totalSlots > 0) {
                    Map<String, Object> dateInfo = new HashMap<>();
                    dateInfo.put("date", date.toString());
                    dateInfo.put("totalSlots", totalSlots);
                    dateInfo.put("availableSlots", availableSlots);
                    availableDates.add(dateInfo);
                }
            }

            // 날짜순으로 정렬
            availableDates.sort((a, b) -> ((String) a.get("date")).compareTo((String) b.get("date")));

            log.info("예약 가능한 날짜 조회 성공 - courseSeq: {}, 총 {}일", courseSeq, availableDates.size());

            return ResponseEntity.ok(availableDates);

        } catch (Exception e) {
            log.error("예약 가능한 날짜 조회 중 오류 발생 - courseSeq: {}", courseSeq, e);

            // 에러 발생 시 빈 리스트 반환
            return ResponseEntity.ok(new ArrayList<>());
        }
    }

    /**
     * 특정 날짜의 시간대 조회 API
     */
    @GetMapping("/timeslots")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getTimeSlots(
            @RequestParam Long courseSeq,
            @RequestParam String date) {

        log.info("=== timeslots API 호출됨 ===");
        log.info("받은 courseSeq: '{}', 타입: {}", courseSeq, courseSeq != null ? courseSeq.getClass().getSimpleName() : "null");
        log.info("받은 date: '{}', 타입: {}", date, date != null ? date.getClass().getSimpleName() : "null");

        try {
            // 파라미터 유효성 검증
            if (date == null || date.trim().isEmpty()) {
                log.warn("❌ 날짜 파라미터가 비어있음 - courseSeq: {}, date: '{}'", courseSeq, date);
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("error", "날짜 파라미터가 필요합니다.");
                return ResponseEntity.badRequest().body(Arrays.asList(errorResponse));
            }

            // 날짜 형식 검증
            LocalDate targetDate;
            try {
                targetDate = LocalDate.parse(date.trim());
            } catch (Exception e) {
                log.warn("잘못된 날짜 형식 - courseSeq: {}, date: '{}'", courseSeq, date);
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("error", "올바른 날짜 형식이 아닙니다. (YYYY-MM-DD)");
                return ResponseEntity.badRequest().body(Arrays.asList(errorResponse));
            }

            // 과거 날짜 검증
            if (targetDate.isBefore(LocalDate.now())) {
                log.warn("과거 날짜 요청 - courseSeq: {}, date: '{}'", courseSeq, date);
                return ResponseEntity.ok(new ArrayList<>()); // 과거 날짜는 빈 리스트 반환
            }

            log.info("✅ 파라미터 검증 완료 - courseSeq: {}, targetDate: {}", courseSeq, targetDate);

            // 새로운 Service 메서드를 사용하여 특정 날짜의 스케줄만 조회
            List<CourseSchedule> daySchedules = courseScheduleService.searchScheduleByDate(courseSeq, targetDate);

            log.info("🔍 서비스에서 조회된 스케줄 수: {}", daySchedules.size());

            if (daySchedules.isEmpty()) {
                log.warn("⚠️ 해당 날짜에 스케줄이 없습니다 - courseSeq: {}, date: {}", courseSeq, targetDate);
                // 빈 배열 반환 대신 데이터베이스 전체 조회해서 확인
                List<CourseSchedule> allSchedules = courseScheduleService.searchScheduleByCourseSeq(courseSeq);
                log.info("📊 전체 스케줄 수: {}", allSchedules.size());

                if (!allSchedules.isEmpty()) {
                    log.info("📅 전체 스케줄 날짜들:");
                    for (CourseSchedule schedule : allSchedules) {
                        log.info("  - {}: {} ~ {}",
                                schedule.getCourseDate(),
                                schedule.getCourseStartTime(),
                                schedule.getCourseEndTime());
                    }
                }
            }

            List<Map<String, Object>> timeSlots = new ArrayList<>();

            for (CourseSchedule schedule : daySchedules) {
                Map<String, Object> slot = new HashMap<>();
                slot.put("scheduleId", schedule.getScheduleId());
                slot.put("courseStartTime", schedule.getCourseStartTime());
                slot.put("courseEndTime", schedule.getCourseEndTime());
                slot.put("courseCapacity", schedule.getCourseCapacity());
                slot.put("bookedSeats", schedule.getBookedSeats());
                slot.put("courseLocation", schedule.getCourseLocation());
                slot.put("status", schedule.getStatus());

                timeSlots.add(slot);

                log.info("📋 스케줄 정보 - ID: {}, 시간: {} ~ {}, 정원: {}, 예약: {}",
                        schedule.getScheduleId(),
                        schedule.getCourseStartTime(),
                        schedule.getCourseEndTime(),
                        schedule.getCourseCapacity(),
                        schedule.getBookedSeats());
            }

            // 시간순으로 정렬
            timeSlots.sort((a, b) -> ((String) a.get("courseStartTime")).compareTo((String) b.get("courseStartTime")));

            log.info("✅ 시간대 조회 성공 - courseSeq: {}, date: {}, 총 {}개 시간대", courseSeq, date, timeSlots.size());

            return ResponseEntity.ok(timeSlots);

        } catch (Exception e) {
            log.error("시간대 조회 중 오류 발생 - courseSeq: {}, date: '{}'", courseSeq, date, e);

            // 에러 발생 시 빈 리스트 반환
            return ResponseEntity.ok(new ArrayList<>());
        }
    }

    @PostMapping("/heartbeat")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> heartbeat(@RequestBody Map<String, Object> data) {
        try {
            Long courseSeq = (Long) data.get("courseSeq");
            int memberNo = (Integer) data.get("memberNo");

            reservationRedisService.updateHeartBeat(courseSeq, memberNo);

            Long activeMember = reservationRedisService.getActiveMemberCount(courseSeq);
            boolean queueActive = reservationRedisService.shouldActivateQueue(courseSeq);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("activeMember", activeMember);
            response.put("queueActive", queueActive);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("하트비트 실패", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "하트비트실패 ");
            return ResponseEntity.ok(response);

        }
    }

    @PostMapping("/leave")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> leavePage(@RequestBody Map<String, Object> data) {
        try{
            Long courseSeq = (Long) data.get("courseSeq");
            int memberNo = (Integer) data.get("memberNo");

            reservationRedisService.removeFromQueue(courseSeq, memberNo);

            log.info("사용자 이탈 강의{}, 사용자{}", courseSeq, memberNo);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            return ResponseEntity.ok(response);
        }catch (Exception e){
            log.error("페이지 이탈 실패", e);
            return ResponseEntity.ok(Map.of("success", false));
        }
    }


    /**
     * 예약 가능한 스케줄만 조회 (달력 최적화용)
     */
    @GetMapping("/available-schedules")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getAvailableSchedules(
            @RequestParam Long courseSeq) {

        try {
            // 예약 가능한 스케줄만 조회
            List<CourseSchedule> availableSchedules = courseScheduleService.searchAvailableSchedules(courseSeq);

            List<Map<String, Object>> schedules = new ArrayList<>();

            for (CourseSchedule schedule : availableSchedules) {
                Map<String, Object> scheduleInfo = new HashMap<>();
                scheduleInfo.put("scheduleId", schedule.getScheduleId());
                scheduleInfo.put("courseDate", schedule.getCourseDate().toString());
                scheduleInfo.put("courseStartTime", schedule.getCourseStartTime());
                scheduleInfo.put("courseEndTime", schedule.getCourseEndTime());
                scheduleInfo.put("courseCapacity", schedule.getCourseCapacity());
                scheduleInfo.put("bookedSeats", schedule.getBookedSeats());
                scheduleInfo.put("availableSeats", schedule.getCourseCapacity() - schedule.getBookedSeats());
                scheduleInfo.put("courseLocation", schedule.getCourseLocation());
                scheduleInfo.put("status", schedule.getStatus());

                schedules.add(scheduleInfo);
            }

            log.info("예약 가능한 스케줄 조회 성공 - courseSeq: {}, 총 {}개", courseSeq, schedules.size());

            return ResponseEntity.ok(schedules);

        } catch (Exception e) {
            log.error("예약 가능한 스케줄 조회 중 오류 발생 - courseSeq: {}", courseSeq, e);

            // 에러 발생 시 빈 리스트 반환
            return ResponseEntity.ok(new ArrayList<>());
        }
    }

    /**
     * 예약 처리
     */
    @PostMapping("/book")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> bookReservation(
            @RequestBody Map<String, Object> reservationData) {

        try {
            // memberNo 추가 (세션에서 가져와야 함 - 임시로 테스트용)
            if (!reservationData.containsKey("memberNo")) {
                reservationData.put("memberNo", (int)(System.currentTimeMillis() % 1000));
            }

            log.info("📋 예약 요청: {}", reservationData);

            // 🎯 실제 Redis 서비스로 예약 처리 (대기열 포함)
            Map<String, Object> result = reservationRedisService.processReservationRequest(reservationData);

            log.info("📋 예약 처리 결과: {}", result);

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            log.error("예약 처리 중 오류 발생", e);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "예약 처리 중 오류가 발생했습니다: " + e.getMessage());
            
            return ResponseEntity.ok(response);
        }
    }

    /**
     * 대기열 상태 조회
     */
    @GetMapping("/queue-status/{courseSeq}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getQueueStatus(@PathVariable Long courseSeq, @RequestParam int memberNo) {
        try {
            
            // 현재 사용자의 대기열 위치
            Map<String, Object> queuePosition = reservationRedisService.getQueuePosition(courseSeq, memberNo);
            
            // 활성 사용자 수
            Long activeMembers = reservationRedisService.getActiveMemberCount(courseSeq);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("userPosition", queuePosition);
            response.put("activeMembers", activeMembers);
            response.put("queueActive", reservationRedisService.shouldActivateQueue(courseSeq));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("대기열 상태 조회 실패", e);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "대기열 상태 조회 실패");
            
            return ResponseEntity.ok(response);
        }
    }

    /**
     * 🎯 전체 대기열 통계 조회 (모니터링용)
     */
    @GetMapping("/queue-stats/{courseSeq}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getQueueStats(@PathVariable Long courseSeq) {
        try {
            // 활성 사용자 수
            Long activeMembers = reservationRedisService.getActiveMemberCount(courseSeq);
            boolean queueActive = reservationRedisService.shouldActivateQueue(courseSeq);
            
            // 대기열 전체 통계
            String queueKey = "queue:course:" + courseSeq;
            Long totalInQueue = redisTemplate.opsForZSet().count(queueKey, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY);
            
            // 상위 10명 대기열 정보
            Set<Object> topMembers = redisTemplate.opsForZSet().range(queueKey, 0, 9);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("activeMembers", activeMembers);
            response.put("queueActive", queueActive);
            response.put("totalInQueue", totalInQueue);
            response.put("topMembers", topMembers);
            
            log.info("🔍 대기열 통계 조회 - courseSeq: {}, 활성사용자: {}, 대기열: {}, 총대기: {}, topMembers: {}", 
                courseSeq, activeMembers, queueActive, totalInQueue, topMembers);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("대기열 통계 조회 실패", e);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "대기열 통계 조회 실패");
            
            return ResponseEntity.ok(response);
        }
    }

    /**
     * 임시 예약 상태 확인 (결제 페이지용)
     */
    @GetMapping("/temp-reservation/{tempReservationId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkTempReservation(@PathVariable String tempReservationId) {
        try {
            
            // Redis에서 임시 예약 정보 조회
            String tempKey = "temp_reservation:" + tempReservationId;
            Map<String, Object> tempReservation = (Map<String, Object>) redisTemplate.opsForValue().get(tempKey);
            
            if (tempReservation == null) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "임시 예약을 찾을 수 없거나 만료되었습니다");
                return ResponseEntity.ok(response);
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", tempReservation);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("임시 예약 확인 실패: {}", tempReservationId, e);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "임시 예약 확인 실패");
            
            return ResponseEntity.ok(response);
        }
    }


}
