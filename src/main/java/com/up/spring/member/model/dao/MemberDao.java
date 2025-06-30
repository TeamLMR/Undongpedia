package com.up.spring.member.model.dao;

import com.up.spring.coach.model.dto.CoachApply;
import com.up.spring.member.model.dto.Member;
import org.apache.ibatis.session.SqlSession;

public interface MemberDao {
    Member searchById(SqlSession session, String memberId);
    int saveMember(SqlSession session, Member member);
    int updateMember(SqlSession session, Member member);

    CoachApply getCoachApply(SqlSession session, Long memberNo);
    int updateCoachApply(SqlSession session, CoachApply coachApply);
    int insertCoachApply(SqlSession session, CoachApply coachApply);
}
