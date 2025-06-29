package com.up.spring.member.model.service;

import com.up.spring.coach.model.dto.CoachApply;
import com.up.spring.member.model.dao.MemberDao;
import com.up.spring.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;


@Service
@RequiredArgsConstructor
public class MemberServiceImpl implements MemberService {

    private final SqlSession session;


    private final MemberDao memberDaoImpl;

    @Override
    public Member searchById(String memberId) {
        return memberDaoImpl.searchById(session, memberId);
    }

    @Override
    public int saveMember(Member member) {
        return memberDaoImpl.saveMember(session, member);
    }

    @Override
    public int updateMember(Member member) {
        return 0;
    }

    @Override
    public CoachApply getCoachApply(Long memberNo) {
        return memberDaoImpl.getCoachApply(session, memberNo);
    }

    @Override
    public int updateCoachApply(CoachApply coachApply) {
        return memberDaoImpl.updateCoachApply(session, coachApply);
    }

    @Override
    public int insertCoachApply(CoachApply coachApply) {
        return memberDaoImpl.insertCoachApply(session, coachApply);
    }
}
