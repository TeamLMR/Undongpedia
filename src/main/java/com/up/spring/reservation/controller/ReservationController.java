package com.up.spring.reservation.controller;

import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.CourseSchedule;
import com.up.spring.course.model.service.CourseService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.*;

@Controller
@RequestMapping("/reservation")
@RequiredArgsConstructor
@Slf4j
public class ReservationController {

    private final CourseService courseService;

    @GetMapping("/{courseSeq}")
    public String reservationPage(@PathVariable Long courseSeq, Model model) {
        try {
            // 실제 DB에서 강의 정보 조회
            Course course = courseService.searchById(courseSeq);
            
            if (course == null) {
                // 강의가 없는 경우 에러 페이지로 리다이렉트하거나 404 처리
                model.addAttribute("errorMessage", "존재하지 않는 강의입니다.");
                return "common/error"; // 에러 페이지가 있다면
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
    public String test(Model model){
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
     * 예약 가능한 날짜 목록 조회 API
     */
    @GetMapping("/available-dates")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getAvailableDates(
            @RequestParam Long courseSeq) {
        
        List<Map<String, Object>> availableDates = new ArrayList<>();
        
        // 임시 더미 데이터 (실제로는 DB에서 CourseSchedule을 조회해야 함)
        LocalDate today = LocalDate.now();
        for (int i = 1; i <= 30; i += 2) { // 격일로 스케줄 생성
            LocalDate date = today.plusDays(i);
            
            Map<String, Object> dateInfo = new HashMap<>();
            dateInfo.put("date", date.toString());
            dateInfo.put("totalSlots", Math.random() > 0.3 ? (int)(Math.random() * 3) + 1 : 0); // 1-3개 또는 0개 슬롯
            dateInfo.put("availableSlots", Math.random() > 0.2 ? (int)(Math.random() * 10) + 1 : 0); // 1-10개 또는 0개 가능
            
            if ((Integer) dateInfo.get("totalSlots") > 0) {
                availableDates.add(dateInfo);
            }
        }
        
        return ResponseEntity.ok(availableDates);
    }
    
    /**
     * 특정 날짜의 시간대 조회 API
     */
    @GetMapping("/timeslots")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getTimeSlots(
            @RequestParam Long courseSeq,
            @RequestParam String date) {
        
        List<Map<String, Object>> timeSlots = new ArrayList<>();
        
        // 임시 더미 데이터 (실제로는 DB에서 CourseSchedule을 조회해야 함)
        String[] times = {"09:00-10:00", "10:00-11:00", "11:00-12:00", "14:00-15:00", "15:00-16:00", "16:00-17:00"};
        String[] locations = {"스튜디오 A", "스튜디오 B", "온라인 클래스"};
        
        for (int i = 0; i < Math.random() * 4 + 1; i++) { // 1-4개 시간대
            String timeRange = times[(int)(Math.random() * times.length)];
            String[] timeParts = timeRange.split("-");
            
            Map<String, Object> slot = new HashMap<>();
            slot.put("scheduleId", System.currentTimeMillis() + i);
            slot.put("courseStartTime", timeParts[0]);
            slot.put("courseEndTime", timeParts[1]);
            slot.put("courseCapacity", (int)(Math.random() * 10) + 5); // 5-15명
            slot.put("bookedSeats", (int)(Math.random() * 5)); // 0-4명 예약됨
            slot.put("courseLocation", locations[(int)(Math.random() * locations.length)]);
            slot.put("status", "AVAILABLE");
            
            timeSlots.add(slot);
        }
        
        return ResponseEntity.ok(timeSlots);
    }
    
    /**
     * 예약 처리 API
     */
    @PostMapping("/book")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> bookReservation(
            @RequestBody Map<String, Object> reservationData) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 실제로는 여기서 예약 로직 처리
            // 1. 좌석 가용성 확인
            // 2. Redis 분산락을 통한 동시성 제어
            // 3. DB 저장
            // 4. Kafka 이벤트 발행
            
            log.info("예약 요청: {}", reservationData);
            
            // 임시로 성공 응답
            response.put("success", true);
            response.put("reservationId", System.currentTimeMillis());
            response.put("message", "예약이 완료되었습니다.");
            
        } catch (Exception e) {
            log.error("예약 처리 중 오류 발생", e);
            response.put("success", false);
            response.put("message", "예약 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

}
