package com.up.spring.course.controller;

import com.up.spring.coach.model.service.CoachService;
import com.up.spring.common.PageFactory;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Review;
import com.up.spring.course.model.dto.Section;
import com.up.spring.course.model.service.CourseService;
import com.up.spring.member.model.dto.Member;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
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

    @RequestMapping("/course/list")
    public String list() {
        return "course/list";
    }

    @RequestMapping("/course/detail")
    public String detail(Long courseSeq ,Model model) {
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
}
