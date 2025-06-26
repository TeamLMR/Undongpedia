package com.up.spring.payment.model.service;

import com.up.spring.payment.model.dao.CartDao;
import com.up.spring.payment.model.dto.Cart;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Log4j2
@RequiredArgsConstructor
public class CartServiceImpl implements CartService{
    private final CartDao cartDao;
    private final SqlSession session;
    @Override
    public List<Cart> searchCartsByMemberNo(long memberNo) {
        return cartDao.searchCartsByMemberNo(session, memberNo);
    }

    @Override
    public int insertCart(Cart cart) {
        return cartDao.insertCart(session, cart);
    }

    @Override
    public int deleteCartByNo(int cartSeq) {
        return cartDao.deleteCartByNo(session, cartSeq);
    }
}
