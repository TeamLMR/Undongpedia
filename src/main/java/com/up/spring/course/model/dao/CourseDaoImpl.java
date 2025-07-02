package com.up.spring.course.model.dao;

import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Progress;
import com.up.spring.course.model.dto.Review;
import org.apache.ibatis.session.RowBounds;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import java.util.List;

@Repository
public class CourseDaoImpl implements CourseDao {
    @Override
    public Course searchById(SqlSession sqlSession, long courseSeq) {
        return sqlSession.selectOne("course.searchById", courseSeq);
    }

    @Override
    public List<Review> getReviewList(SqlSession sqlSession, long courseSeq, Map<String,Object> params) {
        int cPage= params.get("cPage") == null ? 1 : Integer.parseInt(params.get("cPage").toString());
        int numPerpage= params.get("numPerpage") == null ? 3 : Integer.parseInt(params.get("numPerpage").toString());
        RowBounds rowBounds = new RowBounds(((cPage-1)*numPerpage), numPerpage);
        return sqlSession.selectList("course.getReviewList", courseSeq, rowBounds);
    }

    @Override
    public int getReviewListCount(SqlSession sqlSession, long courseSeq) {
        return sqlSession.selectOne("course.getReviewListCount", courseSeq);
    }

    @Override
    public int getReviewByUser(SqlSession sqlSession, Review review) {
        return sqlSession.selectOne("course.getReviewByUser", review);

    }

    @Override
    public List<Map<String, Object>> getReviewRateList(SqlSession sqlSession, long courseSeq) {
        return sqlSession.selectList("course.getReviewRateList", courseSeq);
    }

    @Override
    public int insertReview(SqlSession sqlSession, Review review) {
        return sqlSession.insert("course.insertReview", review);
    }

    @Override
    public List<Course> searchCourseListByMemberNo(SqlSession sqlSession, long memberNo) {
        return sqlSession.selectList("course.searchCourseListByMemberNo", memberNo);
    }

    @Override
    public Curriculum getFirstCurriculum(SqlSession sqlSession, long courseSeq) {
        return sqlSession.selectOne("course.getFirstCurriculum", courseSeq);
    }

    @Override
    public Curriculum getCurriculumBySeq(SqlSession sqlSession, long currSeq) {
        return sqlSession.selectOne("course.getCurriculumBySeq",currSeq);
    }

    @Override
    public Progress getProgressBySeq(SqlSession sqlSession, Map<String, Object> params) {
        return sqlSession.selectOne("course.getProgressBySeq", params);
    }

    @Override
    public int insertProgress(SqlSession sqlSession, Progress progress) {
        return sqlSession.insert("course.insertProgress", progress);
    }

    @Override
    public int updateProgress(SqlSession sqlSession, Progress progress) {
        return sqlSession.update("course.updateProgress", progress);
    }
}
