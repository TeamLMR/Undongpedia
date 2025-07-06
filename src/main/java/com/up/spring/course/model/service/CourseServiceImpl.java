package com.up.spring.course.model.service;


import com.up.spring.course.model.dao.CourseDao;
import com.up.spring.course.model.dto.*;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class CourseServiceImpl implements CourseService {

    private final CourseDao courseDao;
    private final SqlSession sqlSession;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Value("${kafka.topic.user-events}")
    private String userEventsTopic;

    @Override
    public Course searchById(long courseSeq) {
        return courseDao.searchById(sqlSession, courseSeq);
    }

    @Override
    public List<Course> getCourseApplyList(String status) {
        return courseDao.getCourseApplyList(sqlSession, status);
    }

    @Override
    public int courseApplyConfirm(long courseSeq) {
        int result = courseDao.courseApplyConfirm(sqlSession, courseSeq);

        if (result > 0) {
            Course course = courseDao.searchById(sqlSession, courseSeq);
            if (course != null) {
                try {
                    java.util.Map<String, Object> event = new java.util.HashMap<>();
                    event.put("memberNo", course.getMemberNo());
                    long ts = System.currentTimeMillis();
                    event.put("eventType", "COURSE_APPROVED:" + ts);
                    event.put("title", "코스 승인 완료");
                    event.put("message", "코스 '" + course.getCourseTitle() + "' 이(가) 승인되었습니다.");
                    event.put("link", "coach/coursemanager");
                    kafkaTemplate.send(userEventsTopic, "courseApproved:" + courseSeq, event);
                } catch (Exception e) {
                    // 로깅만 수행하고 비즈니스 로직은 계속 진행
                    e.printStackTrace();
                }
            }
        }

        return result;
    }

    @Override
    public List<Review> getReviewListByCourseSeq(long courseSeq) {
        return courseDao.getReviewListByCourseSeq(sqlSession, courseSeq);
    }

    @Override
    public Map<String,Object> getReviewAjax(long courseSeq, Map<String, Object> params) {
        Map<String,Object> map = new HashMap<>();
        List<Review> reviews = courseDao.getReviewList(sqlSession, courseSeq, params);
        int reviewCount = courseDao.getReviewListCount(sqlSession, courseSeq);
        map.put("reviews", reviews);
        map.put("totalCount", reviewCount);

        return map;
    }

    @Override
    public Map<String,Object> getReviewInfo(long courseSeq) {
        double totalScore = 0;
        int totalCount = 0;
        Map<String,Object> map = new HashMap<>();
        List<Map<String,Object>> reviewRateList = courseDao.getReviewRateList(sqlSession, courseSeq);
        for (Map<String, Object> rate : reviewRateList) {
            int score = ((Number) rate.get("REVIEW_RATE")).intValue();
            int count = ((Number) rate.get("RATE_COUNT")).intValue();
            totalScore += score * count;
            totalCount += count;
        }

        Map<String, Double> widthMap = new HashMap<>();
        for (Map<String, Object> rate : reviewRateList) {
            int count = ((Number) rate.get("RATE_COUNT")).intValue();
            int score = ((Number) rate.get("REVIEW_RATE")).intValue();
            double rateWidth = totalCount > 0 ? (double) count / totalCount * 100 : 0.0;
            widthMap.put(String.valueOf(score), rateWidth);
        }

        double average = totalScore / totalCount;

        map.put("count",courseDao.getReviewListCount(sqlSession, courseSeq));
        map.put("rates", reviewRateList);
        map.put("average", String.format("%.1f", average));
        map.put("widths", widthMap);
        return map;
    }

    @Override
    public int insertReview(Review review) {
        int dupReview = courseDao.getReviewByUser(sqlSession, review);
        if (dupReview > 0) {
            return 0;
        }
        return courseDao.insertReview(sqlSession,review);
    }

    @Override
    public int deleteReview(Review review) {
        return courseDao.deleteReview(sqlSession,review);
    }

    @Override
    public List<Course> searchCourseListByMemberNo(long memberNo) {
        return courseDao.searchCourseListByMemberNo(sqlSession, memberNo);
    }

    @Override
    public Curriculum getFirstCurriculum(long courseSeq) {
        return courseDao.getFirstCurriculum(sqlSession,courseSeq);
    }

    @Override
    public Curriculum getCurriculumBySeq(long currSeq) {
        return courseDao.getCurriculumBySeq(sqlSession,currSeq);
    }

    @Override
    public Progress getProgressBySeq(Map<String, Object> params) {
        return courseDao.getProgressBySeq(sqlSession,params);
    }

    @Override
    public int insertProgress(Progress progress) {
        return courseDao.insertProgress(sqlSession,progress);
    }

    @Override
    public int updateProgress(Progress progress) {
        return courseDao.updateProgress(sqlSession,progress);
    }

    @Override
    public  List<Map<String, Object>> getSectionCurrWithProgress(Map<String, Object> params) {
        return courseDao.getSectionCurrWithProgress(sqlSession,params);
    }

    @Override
    public List<Map<String, Object>> getMyLearningCourse(long memberNo) {
        return courseDao.getMyLearningCourse(sqlSession, memberNo);
    }
}
