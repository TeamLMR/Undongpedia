package com.up.spring.member.model.service;

import com.up.spring.member.model.dto.Member;

public interface MemberService {
    Member searchById(String memberId);

}
