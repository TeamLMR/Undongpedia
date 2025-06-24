package com.up.spring.reservation.controller;

import com.esotericsoftware.minlog.Log;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import lombok.RequiredArgsConstructor;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/reservation")
@RequiredArgsConstructor
@Slf4j
public class ReservationController {

    @GetMapping("")
    public String reservationPage(@RequestParam(required = false) Long courseId, 
                                Model model,
                                RedirectAttributes redirectAttributes) {
        if (courseId == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "코스 ID가 필요합니다.");
            return "redirect:/course/list";
        }

        // TODO: 임시 데이터 - 실제로는 서비스에서 가져와야 함
        model.addAttribute("course", createTempCourse(courseId));
        log.debug("{}",createTempCourse(courseId));
        return "reservation/reservation";
    }

    // 임시 데이터 생성 메서드
    private Object createTempCourse(Long courseId) {
        // TODO: 실제 코스 객체로 대체 필요
        log.debug("실행");
        return new Object() {
            public Long getId() { return courseId; }
            public String getTitle() { return "테스트 코스"; }
            public String getDescription() { return "테스트 코스 설명"; }
            public String getMainImage() { return "/resources/assets/img/product/product-1.webp"; }
            public String getCategory() { return "운동"; }
            public Object getInstructor() { 
                return new Object() {
                    public String getName() { return "테스트 강사"; }
                }; 
            }
            public int getRating() { return 5; }
        };
    }
} 