package com.up.spring.payment.model.dao;

import com.up.spring.payment.model.dto.Cart;
import lombok.RequiredArgsConstructor;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class CartDaoImpl implements CartDao {
    @Override
    public List<Cart> searchCartsByMemberNo(SqlSession session, long memberNo) {
        return session.selectList("searchCartsByMemberNo", memberNo);
    }

    @Override
    public int insertCart(SqlSession session, Cart cart) {
        return session.insert("insertCart", cart);
    }

    @Override
    public int deleteCartByNo(SqlSession session, int cartSeq) {
        return session.delete("deleteCartByNo", cartSeq);
    }
}
