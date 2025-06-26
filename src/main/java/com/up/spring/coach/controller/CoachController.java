package com.up.spring.coach.controller;

import com.up.spring.common.model.dto.Category;
import com.up.spring.coach.model.service.CoachService;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Section;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Date;
import java.util.List;

@Controller
@RequestMapping("/coach")
@Slf4j
public class CoachController {
    @Autowired
    private CoachService coachService;
    @RequestMapping("/dashboard")
    public String dashboard(Model model) {
        return "/coach/dashboard";
    }

    @RequestMapping("/addCourse")
    public String addCourse(Model model) {

        List<Category> categories = coachService.getCategoryAll();
        model.addAttribute("categories", categories);
        return "/coach/add/addCourse";
    }

    @PostMapping("/addCourseSection")
    public String addCourseSection(Course course, Model model, HttpSession session) {
        // 저장 경로
        String realPath = session.getServletContext().getRealPath("/resources/upload/course/thumbnail");
        File dir = new File(realPath);
        if (!dir.exists()) dir.mkdirs();

        // Base64 문자열 (data URI 포함될 수 있음)
        String base64img = course.getCourseThumbnail();
        if (base64img != null && base64img.contains(",")) {
            base64img = base64img.split(",")[1]; // "data:image/jpeg;base64,..." 제거
        }
        // 디코딩
        byte[] imageBytes = Base64.getDecoder().decode(base64img); // Java 8 이상 :contentReference[oaicite:1]{index=1}
        int rnd = (int) (Math.random() * 1000) + 1;
        Date d = new Date(System.currentTimeMillis());
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy_MM_dd_HH_mmss");
        String fileName = "COURSE_" + sdf.format(d) +  "_"+ rnd + ".jpg";

        // 파일 저장
        try (OutputStream os = new FileOutputStream(new File(dir, fileName))) {
            os.write(imageBytes);
        }catch (IOException e) {
            e.printStackTrace();
        }

        // DB에 저장할 경로 설정
        String dbPath = "/resources/upload/course/thumbnail/" + fileName;
        course.setCourseThumbnail(dbPath); // setter 필요
        Long insertTempCourse = coachService.insertTempCourse(course);

        List<Section> sectionList = coachService.getSectionList(course.getCourseSeq());

        model.addAttribute("tempCourseSeq", course.getCourseSeq());
        model.addAttribute("sectionList", sectionList);
        return "/coach/add/addCourseSection";
    }

    @GetMapping("/addCourseSection")
    public String editCourseSection(Long courseSeq, Model model, HttpSession session) {
        List<Section> sectionList = coachService.getSectionList(courseSeq);
        model.addAttribute("sectionList", sectionList);
        model.addAttribute("tempCourseSeq", courseSeq);
        return "/coach/add/addCourseSection";
    }

    @PostMapping("/ajaxAddSection")
    @ResponseBody
    public int ajaxAddSection(Section section) {
        log.debug(section.toString());
        return coachService.insertSection(section);
    }

    @RequestMapping("/insertCurriculum")
    public String insertCurriculum(Curriculum curriculum, Model model,int courseSeq, HttpSession session) {
        if ("UPLOAD".equals(curriculum.getCurrVideoType()) && curriculum.getCurrVideoFile() != null) {
            MultipartFile file = curriculum.getCurrVideoFile();
            if (!file.isEmpty()) {
                try {
                    String realPath = session.getServletContext().getRealPath("/resources/upload/course/videos");
                    File dir = new File(realPath);
                    if (!dir.exists()) dir.mkdirs();

                    int rnd = (int) (Math.random() * 1000) + 1;
                    Date d = new Date(System.currentTimeMillis());
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy_MM_dd_HH_mmss");
                    String fileName =file.getOriginalFilename();
                    int idx = fileName.lastIndexOf('.');
                    String extension = fileName.substring(idx);
                    String fileRename = "COURSE_" + sdf.format(d) + "_" + rnd + extension;

                    File saveFile = new File(dir, fileRename);
                    try (OutputStream os = new FileOutputStream(saveFile)) {
                        os.write(file.getBytes());
                    }

                    log.info("업로드 완료: {}", saveFile.getAbsolutePath());

                    // DB 저장용 정보도 curriculum 객체에 세팅 가능
//                     curriculum.setVideoFileName(fileRename);
                     curriculum.setCurrVideoUrl("/resources/upload/course/videos/" + fileRename);
                     log.debug(curriculum.toString());
                    coachService.insertCurriculum(curriculum);

                } catch (IOException e) {
                    e.printStackTrace();
                    model.addAttribute("error", "파일 업로드 실패");
                    return "errorPage"; // 에러 처리 뷰
                }
            }
        }
        return "redirect:/coach/addCourseSection?courseSeq="+courseSeq;

    }

    @RequestMapping("/courseReview")
    public String courseReview(Model model) {
        return "/coach/management/review";
    }
    @RequestMapping("/courseQna")
    public String courseQna(Model model) {
        return "/coach/management/courseQna";
    }
}
