package com.up.spring.course.controller;

import com.up.spring.coach.model.service.CoachService;
import com.up.spring.common.PageFactory;
import com.up.spring.course.model.dto.*;
import com.up.spring.course.model.service.CourseService;
import com.up.spring.member.model.dto.Member;
import com.up.spring.member.model.service.MemberService;
import com.up.spring.payment.model.dto.Orders;
import com.up.spring.payment.model.service.OrderService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Slf4j
public class CourseController {
    @Autowired
    private PageFactory pageFactory;
    @Autowired
    private CourseService courseService;
    @Autowired
    private CoachService coachService;
    @Autowired
    private OrderService orderService;

    @RequestMapping("/course/list")
    public String list() {
        return "course/list";
    }

    @RequestMapping("/course/detail")
    public String detail(Long courseSeq ,Model model) {
        model.addAttribute("isPaid", false);

        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        if(courseSeq == null) {
            model.addAttribute("msg", "잘못된 요청입니다.");
            model.addAttribute("loc", "/");
            return "common/msg";
        }
        Course c = courseService.searchById(courseSeq);
        if(c == null) {
            model.addAttribute("msg", "잘못된 요청입니다.");
            model.addAttribute("loc", "/");
            return "common/msg";
        }
        if(m.getMemberNo() != null){
            Orders o = new Orders();
            o.setCourseSeq(courseSeq);
            o.setMemberNo(m.getMemberNo());
            if(orderService.isCoursePaidByMember(o) > 0){
                model.addAttribute("isPaid", true);
            }
        }
        List<Section> s = coachService.getSectionList(courseSeq);
        Map<String,Object> r = courseService.getReviewInfo(courseSeq);
        model.addAttribute("course", c);
        model.addAttribute("section", s);
        model.addAttribute("reviewInfoMap", r);
        return "course/detail";
    }

    @RequestMapping("/course/insertReview")
    public String insertReview(Review review, Model model) {
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if(m != null){
            int memberNo = m.getMemberNo().intValue();
            review.setMemberSeq(memberNo);
            int result = courseService.insertReview(review);
            if(result > 0) {
                model.addAttribute("msg", "댓글이 등록 되었습니다.");
                model.addAttribute("loc", "/course/detail?courseSeq="+review.getCourseSeq()+"#reviews-list");
            }else{
                model.addAttribute("msg", "이미 댓글이 작성한 댓글이 있습니다.");
                model.addAttribute("loc", "/course/detail?courseSeq="+review.getCourseSeq()+"#reviews-list");
            }
        }else{
            model.addAttribute("msg", "로그인 후 작성 가능합니다.");
            model.addAttribute("loc", "/course/detail?courseSeq="+review.getCourseSeq()+"#reviews-list");
        }
        return "common/msg";
    }

    @RequestMapping("/course/reviewlistajax")
    @ResponseBody
    public Map<String,Object> reviewListAjax(Long courseSeq,int page ,Model model) {
        int cPage = page;
        int numPerPage = 3;
        Map<String, Object> params = new HashMap<>();
        params.put("cPage", cPage);
        params.put("numPerPage", numPerPage);
        Map<String,Object> reviews = courseService.getReviewAjax(courseSeq,params);
        Map<String,Object> res = new HashMap<>();
        int totalCount = ((Number) reviews.get("totalCount")).intValue();
        res.put("reviews", reviews);
        res.put("page", cPage);
        res.put("pageBar", pageFactory.ajaxPageBar(cPage, numPerPage, totalCount, "/course/reviewlistajax"));
        return res;
    }

    @RequestMapping("/course/viewer")
    public String viewer(Long courseSeq,Long currSeq, Model model) {
        if(courseSeq == null) {
            model.addAttribute("msg", "잘못된 접근입니다.");
            model.addAttribute("loc", "/");
            return "common/msg";
        }
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        if(m == null) {
            model.addAttribute("msg", "잘못된 접근입니다.");
            model.addAttribute("loc", "/");
            return "common/msg";
        }
        Orders o = new Orders();
        o.setCourseSeq(courseSeq);
        o.setMemberNo(m.getMemberNo());

        if(orderService.isCoursePaidByMember(o) > 0){
//            List<Section> s = coachService.getSectionList(courseSeq);
            Map<String, Object> params = Map.of("memberSeq",m.getMemberNo(),"courseSeq",courseSeq);
            List<Map<String, Object>> s = courseService.getSectionCurrWithProgress(params);
            log.debug(s.toString());
            Course c = courseService.searchById(courseSeq);
            Curriculum curriculum = new Curriculum();
            if(currSeq == null) {
                curriculum = courseService.getFirstCurriculum(courseSeq);
            }else{
                curriculum = courseService.getCurriculumBySeq(currSeq);
            }

            model.addAttribute("course", c);
            model.addAttribute("section", s);
            model.addAttribute("curr", curriculum);
            return "course/viewer";
        }else{
            model.addAttribute("msg", "잘못된 접근입니다.");
            model.addAttribute("loc", "/");
            return "common/msg";
        }
    }

    @RequestMapping("/course/getProgress")
    @ResponseBody
    public Progress getProgress(Long currSeq) {
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Map<String,Object> params = new HashMap<>();
        params.put("currSeq", currSeq);
        params.put("memberSeq", m.getMemberNo());
        Progress p =courseService.getProgressBySeq(params);
        return p;
    }

    @RequestMapping("/course/saveProgress")
    @ResponseBody
    public int saveProgress (@RequestBody Progress progress) {
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        progress.setMemberSeq(m.getMemberNo());
        Map<String,Object> params = new HashMap<>();
        params.put("currSeq", progress.getCurrSeq());
        params.put("memberSeq", m.getMemberNo());
        Progress p = courseService.getProgressBySeq(params);
        if(p == null) {
            return courseService.insertProgress(progress);
        }else{
            progress.setPrgSeq(p.getPrgSeq());
            return courseService.updateProgress(progress);
        }
    }
}
