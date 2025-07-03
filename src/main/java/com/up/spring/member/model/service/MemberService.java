package com.up.spring.member.model.service;

import com.up.spring.coach.model.dto.CoachApply;
import com.up.spring.member.model.dto.Member;

public interface MemberService {
    Member searchById(String memberId);
    int saveMember(Member member);
    int updateMemberNickname(Long memberNo, String nickname);
    CoachApply getCoachApply(Long memberNo);
    int updateCoachApply(CoachApply coachApply);
    int insertCoachApply(CoachApply coachApply);

    /**
     * 회원 번호로 이메일 조회
     */
    String findEmailByMemberNo(Long memberNo);

    /**
     * 비밀번호 업데이트
     */
    void updatePassword(Long memberNo, String encodedPassword);

    /**
     * 회원탈퇴
     */
    int withdrawMember(Long memberNo);
}
