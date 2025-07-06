package com.up.spring.payment.model.service;

import com.up.spring.payment.model.dao.OrdersDao;
import com.up.spring.payment.model.dto.OrderDetails;
import com.up.spring.payment.model.dto.Orders;
import com.up.spring.payment.model.dto.OrdersInvoice;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.kafka.core.KafkaTemplate;
import com.up.spring.course.model.service.CourseService;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrdersServiceImpl implements OrderService{
    private final OrdersDao ordersDao;
    private final SqlSession session;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final CourseService courseService;
    private static final String PAYMENT_TOPIC = "payment-events";

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

    private Orders buildOrders(Map<String, Object> detail, long memberNo, long courseSeq){
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

    private Orders buildOfflineOrders(Map<String, Object> detail, long memberNo, long courseSeq, Long scheduleId, String tempReservationId){
        log.debug(detail.toString());
        int totalPayAmount = (int)detail.get("totalPayAmount");

        //만약 primaryPayMeans가 null이면 point처리
        String primaryPayMeans = detail.get("primaryPayMeans").equals("") ? "POINT" :(String) detail.get("primaryPayMeans");

        return Orders.builder()
                .ordersPrice(totalPayAmount)
                .ordersPrimaryPay(primaryPayMeans)
                .memberNo(memberNo)
                .courseSeq(courseSeq)
                .scheduleId(scheduleId)
                .tempReservationId(tempReservationId)
                .courseType("OFF")
                .build();
    }

    @Override
    public List<OrdersInvoice> selectOrdersByPaymentIdAndMemberNo(Map<String, Object> orders) {
        return ordersDao.selectOrdersByPaymentIdAndMemberNo(session, orders);
    }

    @Override
    public int cancelOrderById(int ordersSeq) {
        return ordersDao.cancelOrderById(session, ordersSeq);
    }

    @Override
    public int cancelOrdersByPaymentId(String paymentId) {
        return ordersDao.cancelOrdersByPaymentId(session, paymentId);
    }

    @Override
    public int isCoursePaidByMember(Orders orders) {
        return ordersDao.isCoursePaidByMember(session, orders);
    }

    //TODO:강사님헬프
    @Override
    @Transactional
    public int insertOrderAndOrderDetails(Map<String, Object> res, long memberNo, long courseSeq) {
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

        // Kafka 알림 발행
        try {
            Map<String,Object> evt = new HashMap<>();
            evt.put("memberNo", memberNo);
            evt.put("courseSeq", courseSeq);
            String paymentId = String.valueOf(detail.getOrDefault("paymentId", ""));
            evt.put("eventType", "PAYMENT_SUCCESS" + (paymentId.isBlank() ? "" : (":" + paymentId)));
            evt.put("paymentId", paymentId);
            Object nameObj = detail.get("courseName");
            String courseName;
            if(nameObj == null || String.valueOf(nameObj).isBlank()){
                courseName = courseService.searchById(courseSeq).getCourseTitle();
            } else {
                courseName = String.valueOf(nameObj);
            }
            evt.put("courseName", courseName);
            evt.put("totalPayAmount", detail.get("totalPayAmount"));
            evt.put("timestamp", java.time.LocalDateTime.now().toString());
            kafkaTemplate.send(PAYMENT_TOPIC, evt);
        } catch(Exception ex){
            log.error("결제 성공 이벤트 발행 실패", ex);
        }

        //다 성공했으면 success
        return success;
    }

    @Override
    @Transactional
    public int insertOfflineOrderAndOrderDetails(Map<String, Object> res, long memberNo, long courseSeq, Long scheduleId, String tempReservationId) {
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
        // 중복 예약 방지: 같은 회원이 동일 스케줄 이미 예약했는지 확인
        if(scheduleId != null){
            Map<String,Object> dupParams = new java.util.HashMap<>();
            dupParams.put("memberNo", memberNo);
            dupParams.put("scheduleId", scheduleId);
            int dupCnt = ordersDao.existsScheduleReservation(session, dupParams);
            if(dupCnt>0){
                log.warn("중복 스케줄 예약 시도 차단 - memberNo:{}, scheduleId:{}", memberNo, scheduleId);
                return fail;
            }
        }

        //오프라인 order 객체 생성
        Orders ordersData = buildOfflineOrders(detail, memberNo, courseSeq, scheduleId, tempReservationId);
        if (ordersData == null) {
            return fail;
        }
        log.debug("오프라인 주문 데이터: {}", ordersData.toString());
        
        //오프라인 order insert
        int orderResult = ordersDao.insertOfflineOrder(session, ordersData);
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

        // Kafka 알림 발행 (오프라인 결제)
        try {
            java.util.Map<String,Object> evt = new java.util.HashMap<>();
            evt.put("memberNo", memberNo);
            evt.put("courseSeq", courseSeq);
            String paymentId2 = String.valueOf(detail.getOrDefault("paymentId", ""));
            evt.put("eventType", "PAYMENT_SUCCESS" + (paymentId2.isBlank()? "" : (":" + paymentId2)));
            evt.put("paymentId", paymentId2);
            Object nameObj2 = detail.get("courseName");
            String courseName2;
            if(nameObj2 == null || String.valueOf(nameObj2).isBlank()){
                courseName2 = courseService.searchById(courseSeq).getCourseTitle();
            } else {
                courseName2 = String.valueOf(nameObj2);
            }
            evt.put("courseName", courseName2);
            evt.put("totalPayAmount", detail.get("totalPayAmount"));
            evt.put("timestamp", java.time.LocalDateTime.now().toString());
            kafkaTemplate.send(PAYMENT_TOPIC, evt);
        } catch(Exception ex){
            log.error("오프라인 결제 성공 이벤트 발행 실패", ex);
        }

        log.debug("Offline Order, OrderDetails Inserted Successfully");
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
