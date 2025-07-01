package com.up.spring.member.model.service;

import com.up.spring.coach.model.dto.CoachApply;
import com.up.spring.member.model.dao.MemberDao;
import com.up.spring.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
@RequiredArgsConstructor
public class MemberServiceImpl implements MemberService {

    private final SqlSession session;


    private final MemberDao memberDao;

    @Override
    public Member searchById(String memberId) {
        return memberDao.searchById(session, memberId);
    }

    @Override
    @Transactional
    public int saveMember(Member member) {
        return memberDao.saveMember(session, member);
    }

    @Override
    public int updateMemberNickname(Long memberNo, String nickname) {
        return memberDao.updateMemberNickname(session, memberNo, nickname);
    }

    @Override
    public CoachApply getCoachApply(Long memberNo) {
        return memberDao.getCoachApply(session, memberNo);
    }

    @Override
    public int updateCoachApply(CoachApply coachApply) {
        return memberDao.updateCoachApply(session, coachApply);
    }

    @Override
    public int insertCoachApply(CoachApply coachApply) {
        return memberDao.insertCoachApply(session, coachApply);
    }

    @Override
    public String findEmailByMemberNo(Long memberNo) {
        Member member = memberDao.selectOne(session, memberNo);
        return member != null ? member.getMemberId() : null;
    }

    @Override
    @Transactional
    public void updatePassword(Long memberNo, String encodedPassword) {
        Member member = Member.builder()
                .memberNo(memberNo)
                .memberPassword(encodedPassword)
                .build();
        memberDao.updatePassword(session, member);
    }
}
