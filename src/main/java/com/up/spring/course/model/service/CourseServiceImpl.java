package com.up.spring.course.model.service;


import com.up.spring.course.model.dao.CourseDao;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Review;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Transactional
@RequiredArgsConstructor
public class CourseServiceImpl implements CourseService {

    private final CourseDao courseDao;
    private final SqlSession sqlSession;

    @Override
    public Course searchById(long courseSeq) {
        return courseDao.searchById(sqlSession, courseSeq);
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
}
