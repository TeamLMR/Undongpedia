package com.up.spring.course.model.dao;

import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Progress;
import com.up.spring.course.model.dto.Review;
import org.apache.ibatis.session.SqlSession;

import java.util.List;
import java.util.Map;

public interface CourseDao {
    Course searchById(SqlSession sqlSession, long courseSeq);
    List<Course> searchCourseListByMemberNo(SqlSession sqlSession, long memberNo);
    List<Review> getReviewList(SqlSession sqlSession, long courseSeq, Map<String, Object> params);
    int getReviewListCount(SqlSession sqlSession, long courseSeq);
    int getReviewByUser(SqlSession sqlSession, Review review);
    List<Map<String, Object>> getReviewRateList(SqlSession sqlSession, long courseSeq);
    int insertReview(SqlSession sqlSession, Review review);
    Curriculum getFirstCurriculum(SqlSession sqlSession, long courseSeq);
    Curriculum getCurriculumBySeq(SqlSession sqlSession, long currSeq);
    Progress getProgressBySeq(SqlSession sqlSession, Map<String,Object> params);
    int insertProgress(SqlSession sqlSession, Progress progress);
    int updateProgress(SqlSession sqlSession, Progress progress);
}
