package com.up.spring.payment.model.service;

import com.up.spring.payment.model.dto.OrderDetails;
import com.up.spring.payment.model.dto.Orders;

import java.util.List;
import java.util.Map;

public interface OrderService {
    int insertOrder(Orders order);
    int insertOrderDetails(OrderDetails details);
    int insertOrderAndOrderDetails(Map<String, Object> res, long memberNo, int courseSeq);
    Orders selectOrderById(int ordersSeq);
    List<Orders> selectOrdersByMember(Long memberNo);
}
