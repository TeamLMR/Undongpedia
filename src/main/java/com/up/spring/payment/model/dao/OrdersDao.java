package com.up.spring.payment.model.dao;

import com.up.spring.payment.model.dto.OrderDetails;
import com.up.spring.payment.model.dto.Orders;
import org.apache.ibatis.session.SqlSession;

import java.util.List;

public interface OrdersDao {
    int insertOrder(SqlSession session, Orders order);
    int insertOrderDetails(SqlSession session, OrderDetails details);
    Orders selectOrderById(SqlSession session, int ordersSeq);
    List<Orders> selectOrdersByMember(SqlSession session, Long memberNo);
}