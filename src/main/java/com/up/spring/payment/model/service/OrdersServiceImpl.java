package com.up.spring.payment.model.service;

import com.up.spring.payment.model.dao.OrdersDao;
import com.up.spring.payment.model.dto.OrderDetails;
import com.up.spring.payment.model.dto.Orders;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrdersServiceImpl implements OrderService{
    private final OrdersDao ordersDao;
    private final SqlSession session;

    private Timestamp formatToTimestamp(String yyyyMMddHHmmss) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        Date date = null;
        try {
            date = sdf.parse(yyyyMMddHHmmss);
        } catch (ParseException e) {
            log.error(e.getMessage());
        }
        Timestamp timestamp = new Timestamp(date.getTime());
        log.debug(timestamp.toString());
        return timestamp;
    }

    private Orders buildOrders(Map<String, Object> detail, long memberNo, int courseSeq){
        log.debug(detail.toString());
        int totalPayAmount =(int)detail.get("totalPayAmount");

        //만약 primaryPayMeans가 null이면 point처리
        String primaryPayMeans = detail.get("primaryPayMeans").equals("") ? "POINT" :(String) detail.get("primaryPayMeans");

        return Orders.builder()
                .ordersPrice(totalPayAmount)
                .ordersPrimaryPay(primaryPayMeans)
                .memberNo(memberNo)
                .courseSeq(courseSeq)
                .build();
    }

    private OrderDetails buildOrderDetails(Map<String, Object> detail){
        String bankCorpCode = detail.get("bankCorpCode") != null ? (String) detail.get("bankCorpCode") : "";
        String bankAccountNo = detail.get("bankAccountNo") != null ? (String) detail.get("bankAccountNo") : "";
        String cardCorpCode = detail.get("cardCorpCode") != null ? (String) detail.get("cardCorpCode") : "";
        String cardNo = detail.get("cardNo") != null ? (String) detail.get("cardNo") : "";
        String paymentId = detail.get("paymentId") != null ? (String) detail.get("paymentId") : "";
        String ordersPayhistId = detail.get("payHistId") != null ? (String) detail.get("payHistId") : "";
        return OrderDetails.builder()
                .ordersBank(bankCorpCode)
                .ordersAccountNo(bankAccountNo)
                .ordersCardCorp(cardCorpCode)
                .ordersCardNo(cardNo)
                .ordersPaymentId(paymentId)
                .ordersPayhistId(ordersPayhistId)
                .build();
    }

    @Override
    @Transactional
    public int insertOrderAndOrderDetails(Map<String, Object> res, long memberNo, int courseSeq) {
        int success = 1;
        int fail = 0;
        if (res == null || res.isEmpty()) {
            return fail;
        }
        //detail 사용
        Map<String, Object> body = (Map<String, Object>) res.get("body");
        Map<String, Object> detail = (Map<String, Object>) body.get("detail");

        if (memberNo == 0) {
            return fail;
        }
        if (courseSeq == 0) {
            return fail;
        }
        //order 객체 생성
        Orders ordersData = buildOrders(detail, memberNo, courseSeq);
        if (ordersData == null) {
            return fail;
        }
        log.debug(ordersData.toString());
        //order insert
        int orderResult = insertOrder(ordersData);
        if (orderResult != 1) {
            return fail;
        }

        //orderDetail 객체 생성
        OrderDetails orderDetails = buildOrderDetails(detail);
        if (orderDetails == null) {
            return fail;
        }
        log.debug(orderDetails.toString());

        //orderDetail insert
        int orderDetailResult = insertOrderDetails(orderDetails);
        if (orderDetailResult != 1) {
            return fail;
        }

        log.debug("Order, OrderDetails Inserted Successfully");
        //다 성공했으면 success
        return success;
    }

    @Override
    public int insertOrder(Orders order) {
        return ordersDao.insertOrder(session, order);
    }

    @Override
    public int insertOrderDetails(OrderDetails details) {
        return ordersDao.insertOrderDetails(session, details);
    }

    @Override
    public Orders selectOrderById(int ordersSeq) {
        return ordersDao.selectOrderById(session, ordersSeq);
    }

    @Override
    public List<Orders> selectOrdersByMember(Long memberNo) {
        return ordersDao.selectOrdersByMember(session, memberNo);
    }
}
