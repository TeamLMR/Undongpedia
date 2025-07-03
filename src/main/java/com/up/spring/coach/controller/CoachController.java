package com.up.spring.coach.controller;

import com.up.spring.common.model.dto.Category;
import com.up.spring.coach.model.dto.CoachApply;
import com.up.spring.coach.model.service.CoachService;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.CourseSchedule;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Section;
import com.up.spring.course.model.service.CourseService;
import com.up.spring.course.model.service.CourseScheduleService;
import com.up.spring.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import oracle.jdbc.proxy.annotation.Post;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Controller
@RequestMapping("/coach")
@Slf4j
@RequiredArgsConstructor
public class CoachController {
    private final CoachService coachService;
    private final CourseService courseService;
    private final CourseScheduleService courseScheduleService;

    private long returnMemberNo(){
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        long memberNo = 0;
        if (m != null){
            memberNo = m.getMemberNo();
        }
        return memberNo;
    }

    private Course isExistCourse(long courseSeq){
        return courseService.searchById(courseSeq);
    }

    private boolean canModifyAndDelete(Course course){
        boolean result = false;
        long memberNo = returnMemberNo();

        //1. 코스가 빈값이 아니고 내가 만든 코스가 맞는지
        if (course != null && course.getMemberNo() == memberNo){
            //2. 온라인일때
            if (course.getCourseType().equals("ON")){
                //3. 승인 시간이 없다면 승인
                if (course.getCourseConfirmTime() == null) {
                    result = true;
                }
            }
        }
        //4. 그 외는 fail
        return result;
    }

    @PostMapping("/deletecourse")
    public String deleteCourse(@RequestParam("delCourseSeq")long delCourseSeq, Model model, RedirectAttributes redirectAttributes){
        String loc = "common/msg";

        log.debug("deleteCourse: " + delCourseSeq);
        //1. 코스 정보가 있는지
        Course course = isExistCourse(delCourseSeq);
        if (canModifyAndDelete(course)) {
            //역순으로 확인 후 삭제

            //서비스에서 트렌젝션
            //3-1. 커리큘럼 삭제(있다면)
            //3-2. 섹션 삭제(있다면)
            //3-3. 코스 삭제
            Map<String, Integer> result = coachService.deleteCourseCascade(delCourseSeq);
            int deleteCurrNum = result.get("deleteCurrNum");
            int deleteSectionNum = result.get("deleteSectionNum");
            int deleteCourseNum = result.get("deleteCourseNum");

            //3-4 리다이렉트 메세지 설정
            redirectAttributes.addAttribute("result", "success");
            redirectAttributes.addAttribute("msg", "코스 " + deleteCourseNum +
                     "개, 섹션 " + deleteSectionNum + "개, 커리큘럼 " + deleteCurrNum +
                    "개 삭제를 완료했습니다.");

            //3-5 코스관리 페이지로 이동
            loc = "redirect:/coach/coursemanager";

        } else {
            redirectAttributes.addAttribute("result", "fail");
            redirectAttributes.addAttribute("msg", "삭제가 불가합니다.");
            loc = "redirect:/coach/coursemanager";
        }

        return loc;
    }

    @PostMapping("/modifycourse")
    public String modifyCourse(@RequestParam("modifyCourseSeq")long modifyCourseSeq, Model model){
        log.debug("modifyCourseSeq: " + modifyCourseSeq);
        //1. 코스 정보가 있는지
        //2. 코스의 타입이 온라인인지 (TODO: 타입에따라 수정)
        //3. 코스의 승인 날짜의 존재가 없다면
        //- 승인되지 않은 코스만 수정 가능
        //3-1. 코스
        //3-2. 섹션
        //3-3. 커리큘럼
        return "coach/modifyCourse";
    }

    @RequestMapping("/dashboard")
    public String dashboard(Model model)
    {
        List<Map<String, Object>> dashboardInfo = coachService.getDashboardInfo(returnMemberNo());
        for(Map<String, Object> map : dashboardInfo){
            String key = (String) map.get("DASHKEY");
            Object value = map.get("DASHVALUE");
            model.addAttribute(key, value);
        }

        List<Map<String, Object>> salesList = coachService.getMonthlyEarnings(returnMemberNo()); // 위 SQL 실행

        int[] monthlyTotals = new int[12]; // 0 ~ 11 : Jan ~ Dec

        for (Map<String, Object> row : salesList) {
            int monthIndex = Integer.parseInt((String) row.get("MONTH")) - 1;
            int total = ((Number) row.get("TOTAL")).intValue();
            monthlyTotals[monthIndex] = total;
        }

        model.addAttribute("monthlyTotals", Arrays.toString(monthlyTotals));
        return "/coach/dashboard";
    }

    @RequestMapping("/addCourse")
    public String addCourse(Model model) {

        List<Category> categories = coachService.getCategoryAll();
        model.addAttribute("categories", categories);
        return "/coach/add/addCourse";
    }
    @RequestMapping("/addOfflineCourse")
    public String addOfflineCourse(Model model) {

        List<Category> categories = coachService.getCategoryAll();
        model.addAttribute("categories", categories);
        return "/coach/add/addOfflineCourse";
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
        course.setCourseType("ON");
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
    public String insertCurriculum(Curriculum curriculum, Model model,long courseSeq, HttpSession session) {
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
                     curriculum.setCurrVideoUrl("/resources/upload/course/videos/" + fileRename);

                } catch (IOException e) {
                    e.printStackTrace();
                    model.addAttribute("error", "파일 업로드 실패");
                    return "errorPage"; // 에러 처리 뷰
                }
            }
        }
        coachService.insertCurriculum(curriculum);

        return "redirect:/coach/addCourseSection?courseSeq="+courseSeq;

    }
    @RequestMapping("/coursemanager")
    public String courseManager(Model model) {
        long memberNo = returnMemberNo();
        String loc = "common/msg";
        if(memberNo != 0){
            List<Course> courseList = courseService.searchCourseListByMemberNo(memberNo);
            model.addAttribute("courseList", courseList);
            loc = "/coach/management/course";
        } else {
            model.addAttribute("msg", "로그인을 확인해주세요.");
            model.addAttribute("loc", "/common/msg");
        }
        return loc;
    }

    @RequestMapping("/coursereview")
    public String courseReview(Model model) {
        return "/coach/management/reviews";
    }

    @RequestMapping("/courseqna")
    public String courseQna(Model model) {
        return "/coach/management/qna";
    }

    @RequestMapping("/payment")
    public String coursePayment(Model model) {
        return "/coach/management/payment";
    }

    @PostMapping("/upload/editorImage")
    @ResponseBody
    public Map<String, Object> uploadImageForEditor(@RequestParam("upload") MultipartFile upload, HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();

        try {
            String uploadPath = request.getServletContext().getRealPath("/resources/upload/course/editor");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String originalName = upload.getOriginalFilename();
            String ext = originalName.substring(originalName.lastIndexOf("."));
            String uuidName = UUID.randomUUID().toString() + ext;

            File file = new File(uploadDir, uuidName);
            upload.transferTo(file);

            String fileUrl = request.getContextPath() + "/resources/upload/course/editor/" + uuidName;

            // CKEditor가 요구하는 형식
            response.put("uploaded", 1);
            response.put("fileName", uuidName);
            response.put("url", fileUrl);
        } catch (IOException e) {
            response.put("uploaded", 0);
            Map<String, String> error = new HashMap<>();
            error.put("message", "파일 업로드 중 오류가 발생했습니다.");
            response.put("error", error);
        }

        return response;
    }

    @PostMapping("/addOfflineCourseWithSchedule")
    public String addOfflineCourse(Course course, HttpServletRequest request, Model model, HttpSession session) {
        try {
            int memberNo = course.getMemberNo();
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
            byte[] imageBytes = Base64.getDecoder().decode(base64img);
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
            course.setCourseThumbnail(dbPath);
            course.setCourseType("OFF");
            
            // 코스 등록
            coachService.insertTempCourse(course);
            Long courseSeq = course.getCourseSeq(); // <selectKey>로 설정된 실제 courseSeq 사용



            // 스케줄 등록 처리
            createSchedulesFromRequest(request, courseSeq, course);

            model.addAttribute("msg", "오프라인 코스와 스케줄이 성공적으로 등록되었습니다.");
            model.addAttribute("loc", "/coach/dashboard");

        } catch (Exception e) {

            model.addAttribute("msg", "코스 등록 중 오류가 발생했습니다: " + e.getMessage());
            model.addAttribute("loc", "/coach/addOfflineCourse");
        }

        return "common/msg";
    }

        private void createSchedulesFromRequest(HttpServletRequest request, Long courseSeq, Course course) {

        String courseLocation = request.getParameter("courseLocation");
        String courseCapacityStr = request.getParameter("courseCapacity");
        
        // null 체크
        if (courseLocation == null || courseCapacityStr == null) {
            return;
        }
        
        int courseCapacity = Integer.parseInt(courseCapacityStr);
        

        Pattern schedulePattern = Pattern.compile("schedules\\[(\\d+)\\]\\.(.+)");
        Map<String, String> paramMap = request.getParameterMap().entrySet().stream()
                .collect(HashMap::new, (map, entry) -> {
                    String[] values = entry.getValue();
                    if (values.length > 0) {
                        map.put(entry.getKey(), values[0]);
                    }
                }, HashMap::putAll);


        Map<Integer, Map<String, String>> scheduleGroups = new HashMap<>();
        
        for (Map.Entry<String, String> entry : paramMap.entrySet()) {
            Matcher matcher = schedulePattern.matcher(entry.getKey());
            if (matcher.matches()) {
                int index = Integer.parseInt(matcher.group(1));
                String field = matcher.group(2);
                
                scheduleGroups.computeIfAbsent(index, k -> new HashMap<>())
                        .put(field, entry.getValue());
            }
        }

        
        for (Map<String, String> scheduleData : scheduleGroups.values()) {
            String repeatType = scheduleData.get("repeatType");
            String dayOfWeekStr = scheduleData.get("dayOfWeek");
            String startTime = scheduleData.get("startTime");
            String endTime = scheduleData.get("endTime");
            String startDateStr = scheduleData.get("startDate");
            String endDateStr = scheduleData.get("endDate");

            // 스케줄 데이터 null 체크
            if (repeatType == null || dayOfWeekStr == null || startTime == null || 
                endTime == null || startDateStr == null || endDateStr == null) {

                continue;
            }

            int dayOfWeek = Integer.parseInt(dayOfWeekStr);
            LocalDate startDate = LocalDate.parse(startDateStr, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            LocalDate endDate = LocalDate.parse(endDateStr, DateTimeFormatter.ofPattern("yyyy-MM-dd"));

            
            generateSchedules(courseSeq, courseLocation, courseCapacity, repeatType, dayOfWeek, startTime, endTime, startDate, endDate);
        }
    }

        private void generateSchedules(Long courseSeq, String courseLocation, int courseCapacity, 
                                   String repeatType, int dayOfWeek, String startTime, String endTime, 
                                   LocalDate startDate, LocalDate endDate) {
        
        // 시작 날짜에서 첫 번째 해당 요일 찾기
        LocalDate currentDate = startDate;
        while (currentDate.getDayOfWeek().getValue() != dayOfWeek) {
            currentDate = currentDate.plusDays(1);
            if (currentDate.isAfter(endDate)) {
                return; // 기간 내에 해당 요일이 없음
            }
        }

        // 반복 간격 설정 (매주: 7일, 격주: 14일)
        int interval = "BIWEEKLY".equals(repeatType) ? 14 : 7;

        // 해당 요일마다 스케줄 생성
        while (!currentDate.isAfter(endDate)) {
            CourseSchedule schedule = new CourseSchedule();
            schedule.setCourseSeq(courseSeq);
            schedule.setCourseDate(Date.valueOf(currentDate));
            schedule.setCourseStartTime(startTime);
            schedule.setCourseEndTime(endTime);
            schedule.setCourseCapacity(courseCapacity);
            schedule.setCourseLocation(courseLocation);
            schedule.setBookedSeats(0);
            schedule.setStatus("ACTIVE");

            courseScheduleService.insertSchedule(schedule);
            
            // 다음 스케줄 날짜로 이동 (매주는 7일, 격주는 14일 후)
            currentDate = currentDate.plusDays(interval);
        }
    }

    // 코치 신청 페이지 이동
    @GetMapping("/apply")
    public String coachApplyPage() {
        return "myPage/setting/coachApply";
    }

    // 코치 신청 처리
    @PostMapping("/apply")
    @ResponseBody
    public ResponseEntity<String> submitCoachApply(@RequestBody CoachApply coachApply) {
        // 기본 상태를 D(대기)로 설정
        coachApply.setCoaYn("D");
        coachApply.setMemberNo(returnMemberNo());
        coachService.insertCoachApply(coachApply);
        return ResponseEntity.ok("Success");
    }
}
