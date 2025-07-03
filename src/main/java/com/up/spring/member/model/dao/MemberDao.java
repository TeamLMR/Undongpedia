package com.up.spring.member.model.dao;

import com.up.spring.coach.model.dto.CoachApply;
import com.up.spring.member.model.dto.Member;
import org.apache.ibatis.session.SqlSession;

public interface MemberDao {
    Member searchById(SqlSession session, String memberId);
    int saveMember(SqlSession session, Member member);
    int updateMemberNickname(SqlSession session, Long memberNo, String nickname);

    CoachApply getCoachApply(SqlSession session, Long memberNo);
    int updateCoachApply(SqlSession session, CoachApply coachApply);
    int insertCoachApply(SqlSession session, CoachApply coachApply);

    /**
     * 회원번호로 회원 조회
     */
    Member selectOne(SqlSession session, Long memberNo);

    /**
     * 비밀번호 업데이트
     */
    int updatePassword(SqlSession session, Member member);

    /**
     * 회원탈퇴
     */
    int withdrawMember(SqlSession session, Long memberNo);
}
