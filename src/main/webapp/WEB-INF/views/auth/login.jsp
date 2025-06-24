<%@ page import="java.math.BigInteger" %>
<%@ page import="java.security.SecureRandom" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    Cookie[] cookies = request.getCookies();
    String ambassadorToken = null;
    // 쿠키 배열이 null이 아닌 경우 쿠키를 탐색
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            System.out.println("cc = " + cookie.getName());
            if ("ambassador_token".equals(cookie.getName())) {
                ambassadorToken = cookie.getValue();
            }
        }
    }
%>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>


<main class="main">

    <!-- Page Title -->
    <div class="page-title light-background position-relative">
        <div class="container">
            <nav class="breadcrumbs">
                <ol>
                    <li><a href="${path}">홈</a></li>
                    <li class="current">로그인</li>
                </ol>
            </nav>
            <h1>로그인</h1>
        </div>
    </div><!-- End Page Title -->

    <!-- Login Section -->
    <section id="login" class="login section">
        <div class="container" data-aos="fade-up" data-aos-delay="100">
            <div class="row justify-content-center">
                <div class="col-lg-5 col-md-8" data-aos="zoom-in" data-aos-delay="200">
                    <div class="login-form-wrapper">
                        <div class="login-header text-center">
                            <h2>로그인</h2>
                            <p>운동백과에서 건강한 몸을 만들어요!</p>
                        </div>

                        <form method="post" action="${path}/login.do">
                            <div class="mb-4">
                                <label for="email" class="form-label">이메일</label>
                                <input type="email" class="form-control" id="email" name="memberId"
                                       placeholder="이메일을 입력하세요" required="" autocomplete="email">
                            </div>

                            <div class="mb-3">
                                <div class="d-flex justify-content-between">
                                    <label for="password" class="form-label">비밀번호</label>
                                    <a href="${path}/forgot-password" class="forgot-link">비밀번호를 잊으셨나요?</a>
                                </div>
                                <input type="password" class="form-control" id="password" name="password"
                                       placeholder="비밀번호를 입력하세요" required="" autocomplete="current-password">
                            </div>

                            <div class="mb-4 form-check">
                                <input type="checkbox" class="form-check-input" id="remember" name="remember">
                                <label class="form-check-label" for="remember">로그인 유지</label>
                            </div>

                            <div class="d-grid gap-2 mb-4">
                                <button type="submit" class="btn btn-primary">로그인</button>

                                <%
                                    String path = request.getContextPath();
                                    String clientId = "CBUQIgHQrx9kpSArabUl";//애플리케이션 클라이언트 아이디값";
                                    String redirectURI = URLEncoder.encode("http://localhost:8080/undongpedia/savemember", "UTF-8");
                                    SecureRandom random = new SecureRandom();
                                    String state = new BigInteger(130, random).toString();
                                    String apiURL = "https://nid.naver.com/oauth2.0/authorize?response_type=code"
                                            + "&client_id=" + clientId
                                            + "&redirect_uri=" + redirectURI
                                            + "&state=" + state;
                                    session.setAttribute("state", state);
                                %>

                                <a href="<%=apiURL%>" class="btn naver-login-btn d-flex align-items-center justify-content-center">
                                    <img height="30" width="30" src="<c:url value="/resources/images/naver.png"/>"/>
                                    네이버로 로그인
                                </a>
                            </div>

                            <div class="signup-link text-center">
                                <span>계정이 없으신가요?</span>
                                <a href="${path}/signup">회원가입</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section><!-- /Login Section -->

</main>
<style>
    .naver-login-btn {
        background-color: #03c75a;
        color: white;
        text-decoration: none;
        border: none;
        transition: background-color 0.2s;
    }

    .naver-login-btn:hover {
        background-color: #02b151;
        color: white;
        text-decoration: none;
    }

    .naver-login-btn img {
        margin-right: 8px;
    }
</style>
<script src="https://static.nid.naver.com/js/naveridlogin_js_sdk_2.0.2.js" charset="utf-8"></script>
<%--<script type="text/javascript">--%>
<%--    var naver_id_login = new naver_id_login("YOUR_CLIENT_ID", "YOUR_CALLBACK_URL");--%>
<%--    var state = naver_id_login.getUniqState();--%>
<%--    naver_id_login.setButton("white", 2, 40);--%>
<%--    naver_id_login.setDomain("YOUR_SERVICE_URL");--%>
<%--    naver_id_login.setState(state);--%>
<%--    naver_id_login.setPopup();--%>
<%--    naver_id_login.init_naver_id_login();--%>
<%--</script>--%>
<script>
    var ambassador_token = '';
    var currentUrl = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ':' + window.location.port : '');
    <%if(ambassadorToken!=null){%>
    ambassador_token = '<%=ambassadorToken%>';
    <%}%>

    var naverLogin = new naver.LoginWithNaverId(
        {
            clientId: "CBUQIgHQrx9kpSArabUl", //내 애플리케이션 정보에 cliendId를 입력해줍니다.
            callbackUrl: ${pageContext.request.contextPath}+"/login.do", // 내 애플리케이션 API설정의 Callback URL 을 입력해줍니다.
            isPopup: true,
            callbackHandle: true
        }
    );

    naverLogin.init();
    naverLogin.getLoginStatus(function (status) {
        if (status) {
            var email = naverLogin.user.getEmail(); // 필수로 설정할것을 받아와 아래처럼 조건문을 줍니다.
            var nickname = naverLogin.user.getNickname(); // 필수로 설정할것을 받아와 아래처럼 조건문을 줍니다.
            var name = naverLogin.user.getName(); // 필수로 설정할것을 받아와 아래처럼 조건문을 줍니다.
            if (email == undefined || email == null) {
                alert("이메일은 필수정보입니다. 정보제공을 동의해주세요.");
                naverLogin.reprompt();
                return false;
            }
            if (nickname == undefined || nickname == null) {
                alert("이메일은 필수정보입니다. 정보제공을 동의해주세요.");
                naverLogin.reprompt();
                return false;
            }
            if (name == undefined || name == null) {
                alert("이메일은 필수정보입니다. 정보제공을 동의해주세요.");
                naverLogin.reprompt();
                return false;
            }
            let params = {email: email, name: name, nickname: nickname, enif: ambassador_token}
            registerAmbassadorChild(params)
            window.location.href = "/member/loginCheckSns?email=" + email + "&name=" + name + "&nickname=" + nickname +"&sns=naver";
        } else {
            console.log("callback 처리에 실패하였습니다.");
        }
    });


    var naverPopUp;

    function openPopUp() {
        naverPopUp = window.open("https://nid.naver.com/nidlogin.logout", "_blank", "toolbar=yes,scrollbars=yes,resizable=yes,width=1,height=1");
    }

    function closePopUp() {
        naverPopUp.close();
    }

    function naverLogout() {
        openPopUp();
        setTimeout(function () {
            closePopUp();
        }, 1000);
        deleteAllCookies();
        localStorage.clear();
        sessionStorage.clear();
    }

</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>