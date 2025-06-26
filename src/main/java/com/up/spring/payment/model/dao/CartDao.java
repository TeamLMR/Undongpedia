package com.up.spring.payment.model.dao;

import com.up.spring.payment.model.dto.Cart;
import org.apache.ibatis.session.SqlSession;

import java.util.List;

public interface CartDao {
    List<Cart> searchCartsByMemberNo(SqlSession session, long memberNo);
    int insertCart(SqlSession session, Cart cart);
    int deleteCartByNo(SqlSession session, int cartSeq);
}
