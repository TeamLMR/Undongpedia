package com.up.spring.member.model.service;

import com.up.spring.member.model.dto.Member;

public interface MemberService {
    Member searchById(String memberId);
    int saveMember(Member member);
    int updateMember(Member member);
}
