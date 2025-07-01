package com.up.spring.member.model.dao;

import com.up.spring.coach.model.dto.CoachApply;
import com.up.spring.member.model.dto.Member;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.Map;

@Repository("memberDao")
public class MemberDaoImpl implements MemberDao {
    @Override
    public Member searchById(SqlSession session, String memberId) {
        return session.selectOne("member.searchById", memberId);
    }

    @Override
    public int saveMember(SqlSession session, Member member) {
        return session.insert("member.saveMember", member);
    }

    @Override
    public int updateMemberNickname(SqlSession session, Long memberNo, String nickname) {
        Map<String, Object> params = new HashMap<>();
        params.put("memberNo", memberNo);
        params.put("memberNickname", nickname);

        return session.update("member.updateMemberNickname", params);
    }

    @Override
    public CoachApply getCoachApply(SqlSession session, Long memberNo) {
        return session.selectOne("coach.getCoachApply", memberNo);
    }

    @Override
    public int updateCoachApply(SqlSession session, CoachApply coachApply) {
        return session.update("coach.updateCoachApply", coachApply);
    }

    @Override
    public int insertCoachApply(SqlSession session, CoachApply coachApply) {
        return session.insert("coach.insertCoachApply", coachApply);
    }

    @Override
    public Member selectOne(SqlSession session, Long memberNo) {
        return session.selectOne("member.selectOne", memberNo);
    }

    @Override
    public int updatePassword(SqlSession session, Member member) {
        return session.update("member.updatePassword", member);
    }
}
