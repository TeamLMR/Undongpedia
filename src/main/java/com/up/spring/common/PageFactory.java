package com.up.spring.common;

import org.springframework.stereotype.Component;

@Component
public class PageFactory {
    public String basicPageBar(int cPage, int numPerPage, int totalData, String url) {
        StringBuffer sb = new StringBuffer();
        int totalPage = (int)(Math.ceil((double)totalData/numPerPage));
        int pageBarSize = 5;
        int pageNo = ((cPage - 1)/pageBarSize * pageBarSize) + 1;
        int pageEnd = pageNo + pageBarSize-1;
        sb.append("<ul class='pagination justify-content-center pagination-sm'>");
        if(pageNo == 1){
            sb.append("<li class='page-item disabled'>");
            sb.append("<a class='page-link' href='#'>이전</a>");
            sb.append("</li>");
        }else{
            sb.append("<li class='page-item'>");
            sb.append("<a class='page-link' href='javascript:fn_paging("+(pageNo-1)+")'>이전</a>");
            sb.append("</li>");
        }

        while(!(pageNo>pageEnd||pageNo>totalPage)){
            if(pageNo == cPage){
                sb.append("<li class='page-item disabled'>");
                sb.append("<a class='page-link' href='#'>"+pageNo+"</a>");
                sb.append("</li>");
            }else{
                sb.append("<li class='page-item'>");
                sb.append("<a class='page-link' href='javascript:fn_paging("+(pageNo)+")'>"+(pageNo)+"</a>");
                sb.append("</li>");
            }
            pageNo++;
        }
        if(pageNo == totalPage){
            sb.append("<li class='page-item disabled'>");
            sb.append("<a class='page-link' href='#'>다음</a>");
            sb.append("</li>");
        }else{
            sb.append("<li class='page-item'>");
            sb.append("<a class='page-link' href='javascript:fn_paging("+(pageNo+1)+")'>다음</a>");
            sb.append("</li>");
        }

        sb.append("</ul>");
        sb.append("<script>");
        sb.append("function fn_paging(pageNo){");
        sb.append("location.assign('"+url+"?cPage='+pageNo);");
        sb.append("}");
        sb.append("</script>");
        return sb.toString();
    }
}
