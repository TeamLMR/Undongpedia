package com.up.spring.payment.model.service;

import com.up.spring.payment.model.dto.Cart;
import org.apache.ibatis.session.SqlSession;

import java.util.List;

public interface CartService {
    List<Cart> searchCartsByMemberNo(long memberNo);
    int insertCart(Cart cart);
    int deleteCartByNo(int cartSeq);
}
