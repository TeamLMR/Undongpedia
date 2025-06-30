package com.up.spring.member.model.service;

import com.up.spring.coach.model.dto.CoachApply;
import com.up.spring.member.model.dto.Member;

public interface MemberService {
    Member searchById(String memberId);
    int saveMember(Member member);
    int updateMember(Member member);
    CoachApply getCoachApply(Long memberNo);
    int updateCoachApply(CoachApply coachApply);
    int insertCoachApply(CoachApply coachApply);
}
