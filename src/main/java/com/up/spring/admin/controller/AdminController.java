package com.up.spring.admin.controller;

import com.up.spring.coach.model.dto.CoachApply;
import com.up.spring.coach.model.service.CoachService;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Section;
import com.up.spring.course.model.service.CourseService;
import com.up.spring.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Controller
@RequestMapping("/admin")
@Slf4j
@RequiredArgsConstructor
public class AdminController {
    private static final Logger logger = LoggerFactory.getLogger(AdminController.class);

    private final CoachService coachService;
    private final CourseService courseService;

    public long returnMemberNo() {
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        long memberNo = 0;
        if (m != null) {
            memberNo = m.getMemberNo();
        }
        return memberNo;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        return "admin/dashboard";
    }

    @GetMapping("/coachConfirm")
    public String coachConfirm(Model model) {
        return "admin/management/coachConfirm";
    }

    @GetMapping("/coach/apply/list")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getCoachApplyList(
            @RequestParam(defaultValue = "") String status,
            @RequestParam(defaultValue = "") String searchKeyword,
            @RequestParam(required = false) String applyDate) {
        log.info("==== 코치 신청 목록 API 호출됨 ====");
        log.info("status: {}, searchKeyword: {}, applyDate: {}", status, searchKeyword, applyDate);
        Map<String, Object> params = new java.util.HashMap<>();
        params.put("status", status);
        params.put("searchKeyword", searchKeyword);
        params.put("applyDate", applyDate);
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("applyList", coachService.getCoachApplyList(params));
        response.put("counts", coachService.getCoachApplyCount());
        log.info("response: {}", response);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/coach/apply/{coaSeq}")
    @ResponseBody
    public ResponseEntity<CoachApply> getCoachApplyDetail(@PathVariable Long coaSeq) {
        log.info("==== 코치 신청 상세 API 호출됨 ====");
        log.info("coaSeq: {}", coaSeq);
        CoachApply apply = coachService.getCoachApplyDetail(coaSeq);
        log.info("apply: {}", apply);
        return ResponseEntity.ok(apply);
    }

    @PostMapping("/coach/apply/{coaSeq}/status")
    @ResponseBody
    public ResponseEntity<String> updateCoachApplyStatus(
            @PathVariable Long coaSeq,
            @RequestParam String status) {
        logger.info("==== 코치 신청 상태변경 API 호출됨 ====");
        logger.info("coaSeq: {}, status: {}", coaSeq, status);
        if (!status.equals("Y") && !status.equals("N")) {
            return ResponseEntity.badRequest().body("Invalid status value");
        }
        coachService.updateCoachApplyStatus(coaSeq, status);
        logger.info("상태변경 완료");
        return ResponseEntity.ok("Success");
    }

    @GetMapping("/coach/statistics")
    @ResponseBody
    public ResponseEntity<Map<String, Integer>> getCoachStatistics() {
        log.info("==== 코치 통계 API 호출됨 ====");
        try {
            Map<String, Integer> stats = coachService.getCoachApplyCount();
            log.info("통계 조회 성공: {}", stats);
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            log.error("통계 조회 중 오류 발생", e);
            Map<String, Integer> errorStats = new HashMap<>();
            errorStats.put("pending", 0);
            errorStats.put("approved", 0);
            errorStats.put("rejected", 0);
            errorStats.put("total", 0);
            return ResponseEntity.ok(errorStats);
        }
    }

    @GetMapping("/courseConfirm")
    public String courseConfirm(Model model) {
        return "admin/management/courseConfirm";
    }

    @PostMapping("/course/apply/list")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getCourseApplyList(@RequestParam String status){
        Map<String, Object> response = new java.util.HashMap<>();

        List<Course> courseList = courseService.getCourseApplyList(status);
        response.put("courseList", courseList);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/course/apply/detail")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getCourseApplyDetail(@RequestParam long courseSeq){
        Map<String, Object> response = new java.util.HashMap<>();

        Course course = courseService.searchById(courseSeq);
        List<Section> section = coachService.getSectionList(courseSeq);
        response.put("course", course);
        response.put("sectionList", section);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/course/apply/confirm")
    public String getCourseApplyConfirm(@RequestParam("confirmCourseSeq") long courseSeq){
        Map<String, Object> response = new java.util.HashMap<>();
        int course = courseService.courseApplyConfirm(courseSeq);
        return "redirect:/admin/courseConfirm";
    }


}

