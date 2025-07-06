package com.up.spring.course.model.dao;

import com.up.spring.course.model.dto.*;
import org.apache.ibatis.session.SqlSession;

import java.util.List;
import java.util.Map;

public interface CourseDao {
    Course searchById(SqlSession sqlSession, long courseSeq);
    List<Course> getCourseApplyList(SqlSession sqlSession, String status);
    int courseApplyConfirm(SqlSession sqlSession, long courseSeq);
    List<Course> searchCourseListByMemberNo(SqlSession sqlSession, long memberNo);
    List<Review> getReviewListByCourseSeq(SqlSession sqlSession, long courseSeq);
    List<Review> getReviewList(SqlSession sqlSession, long courseSeq, Map<String, Object> params);
    int getReviewListCount(SqlSession sqlSession, long courseSeq);
    int getReviewByUser(SqlSession sqlSession, Review review);
    List<Map<String, Object>> getReviewRateList(SqlSession sqlSession, long courseSeq);
    int insertReview(SqlSession sqlSession, Review review);
    int deleteReview(SqlSession sqlSession, Review review);
    Curriculum getFirstCurriculum(SqlSession sqlSession, long courseSeq);
    Curriculum getCurriculumBySeq(SqlSession sqlSession, long currSeq);
    Progress getProgressBySeq(SqlSession sqlSession, Map<String,Object> params);
    int insertProgress(SqlSession sqlSession, Progress progress);
    int updateProgress(SqlSession sqlSession, Progress progress);
    List<Map<String, Object>> getSectionCurrWithProgress(SqlSession sqlSession, Map<String,Object> params);
    List<Map<String, Object>> getMyLearningCourse(SqlSession sqlSession, long memberNo);

}
