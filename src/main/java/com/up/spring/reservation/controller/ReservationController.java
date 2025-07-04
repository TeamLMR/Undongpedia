package com.up.spring.reservation.controller;

import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.CourseSchedule;
import com.up.spring.course.model.service.CourseService;
import com.up.spring.course.model.service.CourseScheduleService;
import com.up.spring.member.model.dto.Member;
import com.up.spring.reservation.dto.CourseReservationConfig;
import com.up.spring.reservation.service.CourseReservationConfigService;
import com.up.spring.reservation.service.ReservationRedisService;
import com.up.spring.reservation.service.ScheduleCacheService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;

import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;
import java.util.concurrent.TimeUnit;

@Controller
@RequestMapping("/reservation")
@RequiredArgsConstructor
@Slf4j
public class ReservationController {

    private final CourseService courseService;
    private final CourseScheduleService courseScheduleService;
    private final ReservationRedisService reservationRedisService;
    private final RedisTemplate<String, Object> redisTemplate;
    private final CourseReservationConfigService courseReservationConfigService;
    private final ScheduleCacheService scheduleCacheService;

    /**
     * 현재 로그인한 사용자의 memberNo 반환
     * 테스트용: ?testUser=123 파라미터로 가상 사용자 설정 가능
     */
    public long returnMemberNo(){
        try {
            // 테스트 모드: URL 파라미터에서 testUser 값 확인
            HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
            String testUser = request.getParameter("testUser");
            
            if (testUser != null && !testUser.trim().isEmpty()) {
                try {
                    long testMemberNo = Long.parseLong(testUser.trim());
                    log.info("테스트 모드 활성화 - 가상 사용자: {}", testMemberNo);
                    return testMemberNo;
                } catch (NumberFormatException e) {
                    log.warn("잘못된 testUser 파라미터: {}", testUser);
                }
            }
            
            // 일반 모드: 실제 로그인 사용자
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.isAuthenticated() && authentication.getPrincipal() instanceof Member) {
                Member member = (Member) authentication.getPrincipal();
                return member.getMemberNo();
            }
        } catch (Exception e) {
            log.warn("로그인 사용자 정보 조회 실패: {}", e.getMessage());
        }
        return 0; // 비로그인 사용자
    }

    @GetMapping("/{courseSeq}")
    public String reservationPage(@PathVariable Long courseSeq, 
                                @RequestParam(value = "from_queue", required = false) String fromQueue,
                                Model model) {
        log.info("예약페이지 이동{}, from_queue: {}", courseSeq, fromQueue);
        
        //  이벤트 강의인 경우 대기열 통과 토큰 검증
        if(courseReservationConfigService.isEventCourse(courseSeq)) {
            long memberNo = returnMemberNo();
            
            // 로그인한 사용자만 토큰 검증
            if (memberNo > 0) {
                boolean hasPassToken = reservationRedisService.hasQueuePassToken(courseSeq, (int) memberNo);
                
                // 대기열에서 온 경우 더 관대하게 처리
                if ("true".equals(fromQueue)) {
                    if (!hasPassToken) {
                        // 대기열에서 왔는데 토큰이 없으면 토큰 생성 시도
                        log.info(" 대기열에서 온 사용자 - 토큰 생성 시도: 강의{}, 사용자{}", courseSeq, memberNo);
                        
                        String accessToken = "queue_pass:" + courseSeq + ":" + memberNo;
                        redisTemplate.opsForValue().set(accessToken, "PASSED", 5, TimeUnit.MINUTES);
                        log.info(" 임시 토큰 생성 완료: {}", accessToken);
                    }
                    log.info(" 대기열 통과 사용자 - 예약 페이지 진입 허용: 강의{}, 사용자{}", courseSeq, memberNo);
                } else {
                    // 일반 접근인 경우 엄격하게 토큰 검증
                    if (!hasPassToken) {
                        // 토큰이 없으면 대기열로 리다이렉트
                        log.info(" 대기열 통과 토큰 없음 - 대기열 페이지로 리다이렉트: 강의{}, 사용자{}", courseSeq, memberNo);
                        return "redirect:/reservation/queue/" + courseSeq;
                    } else {
                        // 토큰이 있으면 예약 페이지 진입 허용
                        log.info(" 대기열 통과 토큰 확인 - 예약 페이지 진입 허용: 강의{}, 사용자{}", courseSeq, memberNo);
                    }
                }
            } else {
                // 비로그인 사용자는 대기열로
                log.info(" 비로그인 사용자 - 대기열 페이지로 리다이렉트: 강의{}", courseSeq);
                return "redirect:/reservation/queue/" + courseSeq;
            }
        }
        
        if (!courseReservationConfigService.isOpenTime(courseSeq)) {
            log.info("강의 {} - 아직 오픈 시간이 아님, 메인페이지로 리다이렉트", courseSeq);
            return "redirect:/";
        }
        
        // 예약 페이지 진입 시 코스 대기열에서 제거 (대기 순서가 된 경우) - 기존 로직 제거
        // 이제 토큰 기반으로 처리하므로 불필요
        
        Course course = courseService.searchById(courseSeq);
        List<CourseSchedule> schedules = scheduleCacheService.getCourseSchedules(courseSeq);
        model.addAttribute("course", course);
        model.addAttribute("schedules", schedules);
        model.addAttribute("today", LocalDate.now().toString());

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
            List<CourseSchedule> schedules = scheduleCacheService.getCourseSchedules(courseSeq);

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
                log.warn(" 날짜 파라미터가 비어있음 - courseSeq: {}, date: '{}'", courseSeq, date);
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

            log.info("파라미터 검증 완료 - courseSeq: {}, targetDate: {}", courseSeq, targetDate);

            // 새로운 Service 메서드를 사용하여 특정 날짜의 스케줄만 조회
            List<CourseSchedule> daySchedules = courseScheduleService.searchScheduleByDate(courseSeq, targetDate);

            log.info("서비스에서 조회된 스케줄 수: {}", daySchedules.size());

            if (daySchedules.isEmpty()) {
                log.warn("해당 날짜에 스케줄이 없습니다 - courseSeq: {}, date: {}", courseSeq, targetDate);
                // 빈 배열 반환 대신 데이터베이스 전체 조회해서 확인
                List<CourseSchedule> allSchedules = courseScheduleService.searchScheduleByCourseSeq(courseSeq);
                log.info(" 전체 스케줄 수: {}", allSchedules.size());

                if (!allSchedules.isEmpty()) {
                    log.info(" 전체 스케줄 날짜들:");
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
                Integer availableSeats = scheduleCacheService.getAvailableSeats(schedule.getScheduleId());
                slot.put("scheduleId", schedule.getScheduleId());
                slot.put("courseStartTime", schedule.getCourseStartTime());
                slot.put("courseEndTime", schedule.getCourseEndTime());
                slot.put("courseCapacity", schedule.getCourseCapacity());

                slot.put("availableSeats", availableSeats);
                slot.put("bookedSeats", schedule.getCourseCapacity()-availableSeats);

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

            log.info("시간대 조회 성공 - courseSeq: {}, date: {}, 총 {}개 시간대", courseSeq, date, timeSlots.size());

            return ResponseEntity.ok(timeSlots);

        } catch (Exception e) {
            log.error("시간대 조회 중 오류 발생 - courseSeq: {}, date: '{}'", courseSeq, date, e);

            // 에러 발생 시 빈 리스트 반환
            return ResponseEntity.ok(new ArrayList<>());
        }
    }

    @PostMapping("/heartbeat")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> heartbeat(@RequestBody Map<String, Object> data, HttpServletRequest request) {
        try {
            Long courseSeq = Long.valueOf(data.get("courseSeq").toString());
            
            // testUser 파라미터 체크 (부하테스트용)
            String testUserParam = request.getParameter("testUser");
            long memberNo;
            
            if (testUserParam != null) {
                // 테스트 모드: testUser 파라미터 사용
                memberNo = Long.parseLong(testUserParam);
                log.debug("테스트 모드 하트비트 - testUser: {}, courseSeq: {}", memberNo, courseSeq);
            } else {
                // 실제 로그인 사용자의 memberNo 사용
                memberNo = returnMemberNo();
                if (memberNo == 0) {
                    return ResponseEntity.ok(Map.of("success", false, "message", "로그인이 필요합니다."));
                }
            }

            reservationRedisService.updateHeartBeat(courseSeq, (int) memberNo);

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

    /**
     * 코스 대기열 이탈
     */
    @PostMapping("/leave-course-queue")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> leaveCourseQueue(@RequestBody Map<String, Object> data, HttpServletRequest request) {
        try{
            Long courseSeq = Long.valueOf(data.get("courseSeq").toString());
            
            // testUser 파라미터 체크 (부하테스트용)
            String testUserParam = request.getParameter("testUser");
            long memberNo;
            
            if (testUserParam != null) {
                // 테스트 모드: testUser 파라미터 사용
                memberNo = Long.parseLong(testUserParam);
                log.debug("테스트 모드 대기열 이탈 - testUser: {}, courseSeq: {}", memberNo, courseSeq);
            } else {
                // 실제 로그인 사용자의 memberNo 사용
                memberNo = returnMemberNo();
                if (memberNo == 0) {
                    return ResponseEntity.ok(Map.of("success", false, "message", "로그인이 필요합니다."));
                }
            }

            // 🔥 대기열에서 제거
            reservationRedisService.removeFromCourseQueue(courseSeq, (int) memberNo);
            
            // 🔥 대기열 통과 토큰도 함께 제거 (사용자가 나갔을 때)
            String accessToken = "queue_pass:" + courseSeq + ":" + memberNo;
            Boolean tokenDeleted = redisTemplate.delete(accessToken);
            if (tokenDeleted) {
                log.info("🎫 대기열 통과 토큰 제거 - 강의{}, 사용자{}", courseSeq, memberNo);
            }

            log.info("🚪 코스 대기열 이탈 완료 - 강의{}, 사용자{}", courseSeq, memberNo);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            return ResponseEntity.ok(response);
        }catch (Exception e){
            log.error("코스 대기열 이탈 실패", e);
            return ResponseEntity.ok(Map.of("success", false));
        }
    }

    /**
     *  스케줄 대기열 이탈
     */
    @PostMapping("/leave-schedule-queue")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> leaveScheduleQueue(@RequestBody Map<String, Object> data) {
        try{
            Long courseSeq = Long.valueOf(data.get("courseSeq").toString());
            Long scheduleId = Long.valueOf(data.get("scheduleId").toString());
            
            //  실제 로그인 사용자의 memberNo 사용
            long memberNo = returnMemberNo();
            if (memberNo == 0) {
                return ResponseEntity.ok(Map.of("success", false, "message", "로그인이 필요합니다."));
            }

            reservationRedisService.removeFromScheduleQueue(courseSeq, scheduleId, (int) memberNo);

            log.info("스케줄 대기열 이탈 - 강의{}, 스케줄{}, 사용자{}", courseSeq, scheduleId, memberNo);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            return ResponseEntity.ok(response);
        }catch (Exception e){
            log.error("스케줄 대기열 이탈 실패", e);
            return ResponseEntity.ok(Map.of("success", false));
        }
    }

    @PostMapping("/leave")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> leavePage(@RequestBody Map<String, Object> data, HttpServletRequest request) {
        // 하위 호환성을 위해 유지 - 코스 대기열로 리다이렉트
        return leaveCourseQueue(data, request);
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

            //  실제 로그인 사용자의 memberNo 사용
            long memberNo = returnMemberNo();
            if (memberNo == 0) {
                log.warn("⚠️ 로그인하지 않은 사용자의 예약 요청");
                return ResponseEntity.ok(Map.of(
                    "success", false, 
                    "message", "로그인이 필요합니다.",
                    "requireLogin", true
                ));
            }
            
            // 클라이언트에서 전달된 memberNo 무시하고 실제 로그인 사용자 memberNo 사용
            reservationData.put("memberNo", (int) memberNo);
            log.info(" 예약 요청 - 로그인 사용자: {}", memberNo);

            log.info(" 예약 요청: {}", reservationData);

            // 실제 Redis 서비스로 예약 처리 (대기열 포함)
            Map<String, Object> result = reservationRedisService.processReservationRequest(reservationData);

            log.info(" 예약 처리 결과: {}", result);

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
     *  코스 대기열 상태 조회 (이벤트 강의 진입용)
     */
    @GetMapping("/queue-status/{courseSeq}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getQueueStatus(@PathVariable Long courseSeq, @RequestParam int memberNo) {
        try {
            
            // 현재 사용자의 대기열 위치 (코스 레벨)
            Map<String, Object> queuePosition = reservationRedisService.getCourseQueuePosition(courseSeq, memberNo);
            
            // 활성 사용자 수
            Long activeMembers = reservationRedisService.getActiveMemberCount(courseSeq);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("userPosition", queuePosition);
            response.put("activeMembers", activeMembers);
            response.put("queueActive", reservationRedisService.shouldActivateQueue(courseSeq));
            response.put("queueType", "COURSE");
            
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
     *  스케줄 대기열 상태 조회 (예약 모달용)
     */
    @GetMapping("/schedule-queue-status/{courseSeq}/{scheduleId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getScheduleQueueStatus(
            @PathVariable Long courseSeq, 
            @PathVariable Long scheduleId, 
            @RequestParam int memberNo) {
        try {
            
            // 현재 사용자의 대기열 위치 (스케줄 레벨)
            Map<String, Object> queuePosition = reservationRedisService.getScheduleQueuePosition(courseSeq, scheduleId, memberNo);
            
            // 활성 사용자 수
            Long activeMembers = reservationRedisService.getActiveMemberCount(courseSeq);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("userPosition", queuePosition);
            response.put("activeMembers", activeMembers);
            response.put("queueActive", reservationRedisService.shouldActivateQueue(courseSeq));
            response.put("queueType", "SCHEDULE");
            response.put("scheduleId", scheduleId);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("스케줄 대기열 상태 조회 실패", e);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "스케줄 대기열 상태 조회 실패");
            
            return ResponseEntity.ok(response);
        }
    }

    /**
     *  코스 대기열 추가 (이벤트 강의 진입용)
     */
    @PostMapping("/join-course-queue")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> joinCourseQueue(@RequestBody Map<String, Object> data, HttpServletRequest request) {
        try {
            Long courseSeq = Long.valueOf(data.get("courseSeq").toString());
            
            // testUser 파라미터 체크 (부하테스트용)
            String testUserParam = request.getParameter("testUser");
            long memberNo;
            
            if (testUserParam != null) {
                // 테스트 모드: testUser 파라미터 사용
                memberNo = Long.parseLong(testUserParam);
                log.debug("테스트 모드 코스 대기열 - testUser: {}, courseSeq: {}", memberNo, courseSeq);
            } else {
                // 실제 로그인 사용자의 memberNo 사용
                memberNo = returnMemberNo();
                if (memberNo == 0) {
                    return ResponseEntity.ok(Map.of("success", false, "message", "로그인이 필요합니다."));
                }
            }
            
            // 하트비트 업데이트
            reservationRedisService.updateHeartBeat(courseSeq, (int) memberNo);
            
            // 코스 대기열에 추가
            Map<String, Object> result = reservationRedisService.addToCourseQueue(courseSeq, (int) memberNo);
            
            log.info("코스 대기열 추가 요청 - courseSeq: {}, memberNo: {}", courseSeq, memberNo);
            
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            log.error("코스 대기열 추가 실패", e);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "코스 대기열 추가 실패: " + e.getMessage());
            
            return ResponseEntity.ok(response);
        }
    }

    /**
     *  스케줄 대기열 추가 (예약 모달용)
     */
    @PostMapping("/join-schedule-queue")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> joinScheduleQueue(@RequestBody Map<String, Object> data) {
        try {
            Long courseSeq = Long.valueOf(data.get("courseSeq").toString());
            Long scheduleId = Long.valueOf(data.get("scheduleId").toString());
            
            //  실제 로그인 사용자의 memberNo 사용
            long memberNo = returnMemberNo();
            if (memberNo == 0) {
                return ResponseEntity.ok(Map.of("success", false, "message", "로그인이 필요합니다."));
            }
            
            // 하트비트 업데이트
            reservationRedisService.updateHeartBeat(courseSeq, (int) memberNo);
            
            // 스케줄 대기열에 추가
            Map<String, Object> result = reservationRedisService.addToScheduleQueue(courseSeq, scheduleId, (int) memberNo);
            
            log.info(" 스케줄 대기열 추가 요청 - courseSeq: {}, scheduleId: {}, memberNo: {}",
                courseSeq, scheduleId, memberNo);
            
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            log.error("스케줄 대기열 추가 실패", e);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "스케줄 대기열 추가 실패: " + e.getMessage());
            
            return ResponseEntity.ok(response);
        }
    }

    /**
     *  전체 대기열 통계 조회 (모니터링용)
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



    @GetMapping("/queue/{courseSeq}")
    public String queuePage(@PathVariable Long courseSeq, Model model) {
        log.info("대기열 페이지 접속 - courseSeq: {}", courseSeq);
        
        if(!courseReservationConfigService.isEventCourse(courseSeq)) {
            return "redirect:/reservation/"+courseSeq;
        }
        if (!courseReservationConfigService.isOpenTime(courseSeq)) {
            log.info("강의 {} - 아직 오픈 시간이 아님, 메인페이지로 리다이렉트", courseSeq);
            return "redirect:/";
        }
        
        // 🔥 대기열 통과 토큰 검증 - 토큰이 있으면 예약 페이지로 리다이렉트
        long memberNo = returnMemberNo();
        if (memberNo > 0) {
            boolean hasPassToken = reservationRedisService.hasQueuePassToken(courseSeq, (int) memberNo);
            if (hasPassToken) {
                log.info("🎫 대기열 통과 토큰 보유 - 예약 페이지로 리다이렉트: 강의{}, 사용자{}", courseSeq, memberNo);
                return "redirect:/reservation/" + courseSeq + "?from_queue=true";
            }
        }
        
        // 대기열 페이지 진입 시 활성 강의로 등록
        redisTemplate.opsForSet().add("active:courses", courseSeq.toString());
        redisTemplate.expire("active:courses", 24, TimeUnit.HOURS);
        log.info("활성 강의로 등록: {}", courseSeq);
        
        model.addAttribute("courseSeq", courseSeq);
        Course course= courseService.searchById(courseSeq);
        model.addAttribute("course", course);

        return "reservation/queue-waiting";
    }

    /**
     *  임시 관리용 - Redis 락 정리 (개발용)
     */
    @PostMapping("/admin/clear-locks")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> clearRedisLocks(@RequestBody Map<String, Object> request) {
        try {
            String pattern = (String) request.get("pattern");
            if (pattern == null || pattern.isEmpty()) {
                pattern = "temp_occupied:*"; // 기본값
            }
            
            Set<String> keys = redisTemplate.keys(pattern);
            int deletedCount = 0;
            
            if (keys != null && !keys.isEmpty()) {
                redisTemplate.delete(keys);
                deletedCount = keys.size();
            }
            
            log.info(" Redis 락 정리 완료: 패턴={}, 제거된 키 수={}", pattern, deletedCount);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", deletedCount + "개의 락이 제거되었습니다.",
                "deletedCount", deletedCount,
                "deletedKeys", keys != null ? keys : new HashSet<>()
            ));
            
        } catch (Exception e) {
            log.error("Redis 락 정리 실패", e);
            return ResponseEntity.ok(Map.of(
                "success", false,
                "message", "락 정리 중 오류가 발생했습니다."
            ));
        }
    }

    /**
     *  대기열 통과 토큰 생성
     */
    @PostMapping("/create-queue-pass-token")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createQueuePassToken(@RequestBody Map<String, Object> data) {
        try {
            Long courseSeq = Long.valueOf(data.get("courseSeq").toString());
            
            //  실제 로그인 사용자의 memberNo 사용
            long memberNo = returnMemberNo();
            if (memberNo == 0) {
                return ResponseEntity.ok(Map.of("success", false, "message", "로그인이 필요합니다."));
            }
            
            // 대기열에서 첫 번째인지 확인
            boolean isFirstInQueue = reservationRedisService.isFirstInQueue(courseSeq, (int) memberNo);
            if (!isFirstInQueue) {
                return ResponseEntity.ok(Map.of("success", false, "message", "대기 순서가 아닙니다."));
            }
            
            // 토큰 생성 (ReservationRedisService에서 중복 체크 포함)
            String accessToken = "queue_pass:" + courseSeq + ":" + memberNo;
            String existingToken = (String) redisTemplate.opsForValue().get(accessToken);
            
            if (!"PASSED".equals(existingToken)) {
                redisTemplate.opsForValue().set(accessToken, "PASSED", 5, TimeUnit.MINUTES);
                log.info(" 대기열 통과 토큰 생성 (사용자 요청): 강의{}, 사용자{}", courseSeq, memberNo);
            } else {
                log.debug(" 대기열 통과 토큰이 이미 존재함 (사용자 요청): 강의{}, 사용자{}", courseSeq, memberNo);
            }
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "대기열 통과 토큰이 생성되었습니다.",
                "token", accessToken
            ));
            
        } catch (Exception e) {
            log.error("대기열 통과 토큰 생성 실패", e);
            return ResponseEntity.ok(Map.of("success", false, "message", "토큰 생성 실패: " + e.getMessage()));
        }
    }
    
    /**
     * 🔥 대기열 통과 토큰 정리 (개발용)
     */
    @PostMapping("/admin/clear-queue-tokens")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> clearQueueTokens(@RequestBody Map<String, Object> request) {
        try {
            Long courseSeq = (Long) request.get("courseSeq");
            String pattern;
            
            if (courseSeq != null) {
                // 특정 강의의 토큰만 정리
                pattern = "queue_pass:" + courseSeq + ":*";
            } else {
                // 모든 대기열 토큰 정리
                pattern = "queue_pass:*";
            }
            
            Set<String> keys = redisTemplate.keys(pattern);
            int deletedCount = 0;
            
            if (keys != null && !keys.isEmpty()) {
                redisTemplate.delete(keys);
                deletedCount = keys.size();
            }
            
            log.info("🎫 대기열 토큰 정리 완료: 패턴={}, 제거된 토큰 수={}", pattern, deletedCount);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", deletedCount + "개의 대기열 토큰이 제거되었습니다.",
                "deletedCount", deletedCount,
                "pattern", pattern
            ));
            
        } catch (Exception e) {
            log.error("대기열 토큰 정리 실패", e);
            return ResponseEntity.ok(Map.of(
                "success", false,
                "message", "토큰 정리 중 오류가 발생했습니다."
            ));
        }
    }

}
