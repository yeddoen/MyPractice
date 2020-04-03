<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.InputStreamReader"%>
<%@ page import="java.net.URL"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.parser.JSONParser"%>
<%@ page import="java.net.HttpURLConnection"%>
<%@ page import="java.io.IOException"%>
<%@ page import="org.json.simple.parser.ParseException"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
	String apiUrl = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastSpaceData";
	// 홈페이지에서 받은 키
	String serviceKey = "jmlzfLiLkGfg5rfxIRmmaPMdisMIarg7qsfPJXdcrKVFguKUfmaXW8d7SQyze1vz9TFNrsAUrsLHVwy0k13NnA%3D%3D";
	String nx = "60";	//위도
	String ny = "127";	//경도
	String baseDate = "20200403";	//조회하고싶은 날짜 이 예제는 어제 날짜 입력해 주면 됨
	String baseTime = "2300";	//API 제공 시간을 입력하면 됨
	String type = "json";	//타입 xml, json 등등 ..
	String numOfRows = "165";	//한 페이지 결과 수 
	
	/*전날 23시 부터 164개의 데이터를 조회하면 
	오늘 3/6/9/12/15/18/21/내일0/3/6/9/12/15/18/21/내일모레 00시까지의 날씨를 알 수 있음*/
	
	StringBuilder urlBuilder = new StringBuilder(apiUrl);
	urlBuilder.append("?" + URLEncoder.encode("ServiceKey","UTF-8") + "="+serviceKey);
	urlBuilder.append("&" + URLEncoder.encode("nx","UTF-8") + "=" + URLEncoder.encode(nx, "UTF-8")); //경도
	urlBuilder.append("&" + URLEncoder.encode("ny","UTF-8") + "=" + URLEncoder.encode(ny, "UTF-8")); //위도
	urlBuilder.append("&" + URLEncoder.encode("base_date","UTF-8") + "=" + URLEncoder.encode(baseDate, "UTF-8")); /* 조회하고싶은 날짜*/
	urlBuilder.append("&" + URLEncoder.encode("base_time","UTF-8") + "=" + URLEncoder.encode(baseTime, "UTF-8")); 
	/* 조회하고싶은 시간 Base_time  : 0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300 (1일 8회)  */
	urlBuilder.append("&" + URLEncoder.encode("_type","UTF-8") + "=" + URLEncoder.encode(type, "UTF-8"));	/* 타입 */
	urlBuilder.append("&" + URLEncoder.encode("numOfRows","UTF-8") + "=" + URLEncoder.encode(numOfRows, "UTF-8"));	/* 한 페이지 결과 수 */
	
	/*
	 * GET방식으로 전송해서 파라미터 받아오기
	 */
	URL url = new URL(urlBuilder.toString());
	//어떻게 넘어가는지 확인하고 싶으면 아래 출력분 주석 해제
	//System.out.println(url);
	HttpURLConnection conn = (HttpURLConnection) url.openConnection();
	conn.setRequestMethod("GET");
	conn.setRequestProperty("Content-type", "application/json");
	System.out.println("Response code: " + conn.getResponseCode());
	BufferedReader rd;
	if(conn.getResponseCode() >= 200 && conn.getResponseCode() <= 300) {
		rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
	} else {
		rd = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
	}
	StringBuilder sb = new StringBuilder();
	String line;
	while ((line = rd.readLine()) != null) {
		sb.append(line);
	}
	rd.close();
	conn.disconnect();
	String result= sb.toString();
	//System.out.println(result);
	
	
	// Json parser를 만들어 만들어진 문자열 데이터를 객체화 
	JSONParser parser = new JSONParser(); 
	JSONObject obj = (JSONObject) parser.parse(result); 
	// response 키를 가지고 데이터를 파싱 
	JSONObject parse_response = (JSONObject) obj.get("response"); 
	// response 로 부터 body 찾기
	JSONObject parse_body = (JSONObject) parse_response.get("body"); 
	// body 로 부터 items 찾기 
	JSONObject parse_items = (JSONObject) parse_body.get("items");
	
	// items로 부터 itemlist 를 받기 
	JSONArray parse_item = (JSONArray) parse_items.get("item");
	request.setAttribute("parse_item",parse_item);
	//System.out.println(parse_item); item부분만 담김.
	String category;
	JSONObject weather; // parse_item은 배열형태이기 때문에 하나씩 데이터를 하나씩 가져올때 사용
	// 카테고리와 값만 받아오기
	String day="";
	String time="";
%>
<% 
for(int i = 0 ; i < parse_item.size(); i++) {
	weather = (JSONObject) parse_item.get(i);
	Object fcstValue = weather.get("fcstValue");
	Object fcstDate = weather.get("fcstDate");
	Object fcstTime = weather.get("fcstTime");
	//double형으로 받고싶으면 아래내용 주석 해제
	//double fcstValue = Double.parseDouble(weather.get("fcstValue").toString());
	category = (String)weather.get("category"); 
	// 출력
	if(!day.equals(fcstDate.toString())) {
		day=fcstDate.toString();
	}
	if(!time.equals(fcstTime.toString())) {
		time=fcstTime.toString();
	}%>
	<div>예측날짜&시간:<%=day%>&nbsp;<%=time%></div><br/>
	<div>카테고리:<%=category %></div>
	<div>값:<%=fcstValue %></div>
	<div>예측날짜:<%=fcstDate %></div>
	<div>예측시간:<%=fcstTime %></div>
	<p>--------------------------</p>
<%	

}
%>
	<div class="Time">과연 결과는>></div>
	<%--Object parse = request.getAttribute("parse_item");

		
		<%=parse %>
    <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
	<script>
		var aj = eval('<%=parse%>');
		('.Time').append(aj);
	</script>--%>
</body>
</html>