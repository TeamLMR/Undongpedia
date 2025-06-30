package com.up.spring.main.dao;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.main.dto.EventCourse;
import org.apache.ibatis.session.RowBounds;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class MainDaoImpl implements MainDao {
    @Override
    public List<Category> getCategorys(SqlSession session) {
        return session.selectList("getCategorys");
    }

    @Override
    public List<Course> getCourseList(SqlSession session, Map<String, Object> params) {
        int cPage= params.get("cPage") == null ? 1 : Integer.parseInt(params.get("cPage").toString());
        int numPerPage= params.get("numPerPage") == null ? 8 : Integer.parseInt(params.get("numPerPage").toString());
        RowBounds rowBounds = new RowBounds(((cPage-1)*numPerPage), numPerPage);

        return session.selectList("getCourseList", params, rowBounds);
    }

    @Override
    public List<EventCourse> getActiveEventCourses(SqlSession session) {
        List<EventCourse> result = session.selectList("getActiveEventCourses");
        System.out.println("DAO에서 조회된 이벤트 강의 수: " + (result != null ? result.size() : 0));
        return result;
    }
}
