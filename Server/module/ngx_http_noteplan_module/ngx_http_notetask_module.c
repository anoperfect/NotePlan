/*
    notetask nginx module. 
    It's based on taobao tengine team spec about Write nginx module. 
    
*/
#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>
//#include <ngx_thread.h>
#include <inttypes.h>
#define ENTER 
#include "mysql/mysql.h"
typedef struct
{
        ngx_str_t notetask_string;
        //ngx_int_t notetask_counter;
}ngx_http_notetask_loc_conf_t;

static ngx_int_t ngx_http_notetask_init(ngx_conf_t *cf);

static void *ngx_http_notetask_create_loc_conf(ngx_conf_t *cf);

static char *ngx_http_notetask_string(ngx_conf_t *cf, ngx_command_t *cmd,
        void *conf);

//static char *ngx_http_notetask_counter(ngx_conf_t *cf, ngx_command_t *cmd,
        //void *conf);

static ngx_command_t ngx_http_notetask_commands[] = {
   {
                ngx_string("notetask_string"),
                NGX_HTTP_LOC_CONF|NGX_CONF_NOARGS|NGX_CONF_TAKE1,
                ngx_http_notetask_string,
                NGX_HTTP_LOC_CONF_OFFSET,
                offsetof(ngx_http_notetask_loc_conf_t, notetask_string),
                NULL },

#if 0
        
        {
                ngx_string("notetask_counter"),
                NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
                ngx_http_notetask_counter,
                NGX_HTTP_LOC_CONF_OFFSET,
                offsetof(ngx_http_notetask_loc_conf_t, notetask_counter),
                NULL },
#endif

        ngx_null_command
};


/*
static u_char ngx_notetask_default_string[] = "Default String: Hello, world!";
*/
static ngx_http_module_t ngx_http_notetask_module_ctx = {
        NULL,                          /* preconfiguration */
        ngx_http_notetask_init,           /* postconfiguration */

        NULL,                          /* create main configuration */
        NULL,                          /* init main configuration */

        NULL,                          /* create server configuration */
        NULL,                          /* merge server configuration */

        ngx_http_notetask_create_loc_conf, /* create location configuration */
        NULL                            /* merge location configuration */
};


ngx_module_t ngx_http_notetask_module = {
        NGX_MODULE_V1,
        &ngx_http_notetask_module_ctx,    /* module context */
        ngx_http_notetask_commands,       /* module directives */
        NGX_HTTP_MODULE,               /* module type */
        NULL,                          /* init master */
        NULL,                          /* init module */
        NULL,                          /* init process */
        NULL,                          /* init thread */
        NULL,                          /* exit thread */
        NULL,                          /* exit process */
        NULL,                          /* exit master */
        NGX_MODULE_V1_PADDING
};


#define PRINTF_DEBUG(fmt...) do{printf(fmt);/*ngx_log_error(NGX_LOG_EMERG, r->connection->log, 0, fmt);*/}while(0)
#define PRINTF_ERROR(fmt...) do{printf(fmt);ngx_log_error(NGX_LOG_EMERG, r->connection->log, 0, fmt);}while(0)
int query_result_to_cstring(const char* path, char res_string[], size_t size, ngx_http_request_t *r)
{
    int ret = 0;
    res_string[0] = '\0';

    static MYSQL *kconn = NULL;
    static int kconnected = 0;
    static int kconnect_times = 0;
    static int kquery_times = 0;

    if(!kconnected) {
        kconnect_times ++;

        char server[] = "localhost";
        char user[] = "root";
        char password[] = "mysql@ubuntu";
        char database[] = "notetask";
    
        kconn = mysql_init(NULL);
    
        if (!mysql_real_connect(kconn, server,user, password, database, 0, NULL, 0)) {
            PRINTF_ERROR("mysql connect error : %s\n", mysql_error(kconn));
            mysql_close(kconn);
            mysql_library_end();
            kconn = NULL;
            kconnected = 0;
            ret = -1;
            goto finish;
        }
            else {
            PRINTF_DEBUG("mysql connect OK [%d].\n", getpid());
            kconnected = 1;
            }
    }

    //根据请求的path, 组合查询语句.
    #define LEN_QUERY_STRING (1024)
    char query_string[LEN_QUERY_STRING];
    snprintf(query_string, LEN_QUERY_STRING, "%s", "select * from notetask"); 

    int ret_query = mysql_query(kconn, query_string);
    kquery_times ++;
    if(ret_query) {
        PRINTF_ERROR("mysql query error : %s\n", mysql_error(kconn));
        mysql_close(kconn);
        mysql_library_end();
        kconn = NULL;
        kconnected = 0;
        ret = -1;
        goto finish;
    }

    MYSQL_ROW sqlrow;
    MYSQL_RES *res_ptr;

    size_t len = 0;

    res_ptr = mysql_store_result(kconn);

    int64_t uid = 100;
    int type = 1;
    int count = 18;
    int version = 667;
    int status = 0;

    const char* title = "当前任务";
    int page = 1;
    int code = 200;
    int success = 1;
    const char* message = "";
    len += snprintf(res_string, size-len, 
            "{"
                "\"notetasks\":{"
                    "\"uid\":%"PRIu64","
                    "\"type\":%d,"
                    "\"count\":%d,"
                    "\"version\":%d,"
                    "\"server\":\"%d.%d.%d.%d\","
                    "\"status\":%d"
                "},"
                "\"page\":{"
                    "\"title\":\"%s\","
                    "\"page\":%d"
                "},"
                "\"code\":%d,"
                "\"success\":%s,"
                "\"message\":\"%s\","
                "\"notes\":[", 
                    uid,
                    type,
                    count,
                    version,
                    ngx_getpid(), ngx_log_tid, kconnect_times, kquery_times,
                    status,
                    title, 
                    page,
                    code,
                    success?"true":"false",
                    message);

    int row_number = 0;

    if(res_ptr) {
        while((sqlrow = mysql_fetch_row(res_ptr)) && len + 1 < size) {

            row_number ++;

            len += snprintf(res_string + len, size - len, 
                    "%s{"
                        "\"uid\":%s," 
                        "\"status\":%s," 
                        "\"startDateTime\":\"%s\"," 
                        "\"finishDateTime\":\"%s\"," 
                        "\"commitDateTime\":\"%s\"," 
                        "\"updateDateTime\":\"%s\"," 
                        "\"content\":\"%s\","
                        "\"isShared\":%s,"
                        "\"isOnlyLocal\":%s,"
                        "\"isOnlyWorkday\":%s,"
                        "\"isDailyRepeat\":%s,"
                        "\"isWeeklyRepeat\":%s,"
                        "\"isYearlyRepeat\":%s,"
                        "\"commentNumber\":%ld,"
                        "\"likeNumber\":%ld"
                    "}", 
                    row_number > 1 ? "," : "", 
                    sqlrow[1],
                    sqlrow[2],
                    sqlrow[3],
                    sqlrow[4],
                    sqlrow[5],
                    sqlrow[6],
                    sqlrow[7],
                    sqlrow[8],
                    sqlrow[9],
                    sqlrow[10],
                    sqlrow[11],
                    sqlrow[12],
                    sqlrow[13],
                    atol(sqlrow[14]),
                    atol(sqlrow[15])
                        );
        }

        if(len+1 < size) {
            len += snprintf(res_string + len, size - len, 
                "]"
                "}");
        }

        mysql_free_result(res_ptr);
        res_ptr = NULL;
    }
    else {
        PRINTF_ERROR("mysql_use_result error : %s.\n", mysql_error(kconn));
        mysql_close(kconn);
        mysql_library_end();
        kconn = NULL;
        kconnected = 0;
        ret = -1;
        goto finish;
    }

finish:
    return ret;
}


static ngx_int_t
ngx_http_notetask_handler(ngx_http_request_t *r)
{ENTER
        ngx_int_t    rc;
        ngx_buf_t   *b;
        ngx_chain_t  out;
        ngx_http_notetask_loc_conf_t* my_conf;

#define LEN_RESPONSE_STRING (1024*1024)
        u_char ngx_notetask_string[LEN_RESPONSE_STRING] = {0};
        ngx_uint_t content_length = 0;

        ngx_log_error(NGX_LOG_EMERG, r->connection->log, 0, "n1gx_http_notetask_handler is called!");

        my_conf = ngx_http_get_module_loc_conf(r, ngx_http_notetask_module);
        if (my_conf->notetask_string.len == 0 )
        {
                ngx_log_error(NGX_LOG_EMERG, r->connection->log, 0, "notetask_string is empty!");
                return NGX_DECLINED;
        }

#if 0
        if (my_conf->notetask_counter == NGX_CONF_UNSET
                || my_conf->notetask_counter == 0)
        {
                ngx_sprintf(ngx_notetask_string, "%s", my_conf->notetask_string.data);
        }
        else
        {
                ngx_sprintf(ngx_notetask_string, "%s Visited Times:%d", my_conf->notetask_string.data,
                        ++ngx_notetask_visited_times);
        }
#endif

        setbuf(stdout, NULL);
        //char s[LEN_RESPONSE_STRING]; s[0] = '\0';
        int total_times = 1;//100*1024;
        struct timeval tvs;
        struct timeval tve;
        gettimeofday(&tvs, NULL);
        while(total_times --) {
            static int ktest_times = 0;
            query_result_to_cstring("/", (char*)ngx_notetask_string, LEN_RESPONSE_STRING, r);
            ktest_times ++;
            if(0 == ktest_times % 10240) {
                printf(".%zd %d\n", strlen((char*)ngx_notetask_string), ktest_times);
            }
        }
        gettimeofday(&tve, NULL);
        long usec = tve.tv_usec-tvs.tv_usec;
        if(usec >= 0) {
            PRINTF_DEBUG("%ld.%06ld", tve.tv_sec-tvs.tv_sec, usec);
        }
        else {
            PRINTF_DEBUG("%ld.%06ld", tve.tv_sec-tvs.tv_sec-1, usec+1000000);
        }

        PRINTF_DEBUG("notetask_string:%s", ngx_notetask_string);
        content_length = ngx_strlen(ngx_notetask_string);
        PRINTF_DEBUG("[%zd]\n", content_length);

        /* we response to 'GET' and 'HEAD' requests only */
        if (!(r->method & (NGX_HTTP_GET|NGX_HTTP_HEAD|NGX_HTTP_POST))) {
                return NGX_HTTP_NOT_ALLOWED;
        }

        /* discard request body, since we don't need it here */
        rc = ngx_http_discard_request_body(r);

        if (rc != NGX_OK) {
                return rc;
        }

        /* set the 'Content-type' header */
        /*
         *r->headers_out.content_type.len = sizeof("text/html") - 1;
         *r->headers_out.content_type.data = (u_char *)"text/html";
         */
        ngx_str_set(&r->headers_out.content_type, "text/html");


        /* send the header only, if the request type is http 'HEAD' */
        if (r->method == NGX_HTTP_HEAD) {
                r->headers_out.status = NGX_HTTP_OK;
                r->headers_out.content_length_n = content_length;

                return ngx_http_send_header(r);
        }

        /* allocate a buffer for your response body */
        b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
        if (b == NULL) {
                return NGX_HTTP_INTERNAL_SERVER_ERROR;
        }

        /* attach this buffer to the buffer chain */
        out.buf = b;
        out.next = NULL;

        /* adjust the pointers of the buffer */
        b->pos = ngx_notetask_string;
        b->last = ngx_notetask_string + content_length;
        b->memory = 1;    /* this buffer is in memory */
        b->last_buf = 1;  /* this is the last buffer in the buffer chain */

        /* set the status line */
        r->headers_out.status = NGX_HTTP_OK;
        r->headers_out.content_length_n = content_length;

        /* send the headers of your response */
        rc = ngx_http_send_header(r);

        if (rc == NGX_ERROR || rc > NGX_OK || r->header_only) {
                return rc;
        }

        /* send the buffer chain of your response */
        return ngx_http_output_filter(r, &out);
}

static void *ngx_http_notetask_create_loc_conf(ngx_conf_t *cf)
{
        ngx_http_notetask_loc_conf_t* local_conf = NULL;
        local_conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_notetask_loc_conf_t));
        if (local_conf == NULL)
        {
                return NULL;
        }

        ngx_str_null(&local_conf->notetask_string);
        //local_conf->notetask_counter = NGX_CONF_UNSET;

        return local_conf;
}

/*
static char *ngx_http_notetask_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
        ngx_http_notetask_loc_conf_t* prev = parent;
        ngx_http_notetask_loc_conf_t* conf = child;
        ngx_conf_merge_str_value(conf->notetask_string, prev->notetask_string, ngx_notetask_default_string);
        ngx_conf_merge_value(conf->notetask_counter, prev->notetask_counter, 0);
        return NGX_CONF_OK;
}*/

static char *
ngx_http_notetask_string(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{

        ngx_http_notetask_loc_conf_t* local_conf;


        local_conf = conf;
        char* rv = ngx_conf_set_str_slot(cf, cmd, conf);

        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0, "notetask_string:%s", local_conf->notetask_string.data);

        return rv;
}


#if 0
static char *ngx_http_notetask_counter(ngx_conf_t *cf, ngx_command_t *cmd,
        void *conf)
{
        ngx_http_notetask_loc_conf_t* local_conf;
        local_conf = conf;
        char* rv = NULL;
        rv = ngx_conf_set_flag_slot(cf, cmd, conf);
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0, "notetask_counter:%d", local_conf->notetask_counter);
        return rv;
}
#endif


static ngx_int_t
ngx_http_notetask_init(ngx_conf_t *cf)
{
        ngx_http_handler_pt        *h;
        ngx_http_core_main_conf_t  *cmcf;

        cmcf = ngx_http_conf_get_module_main_conf(cf, ngx_http_core_module);

        h = ngx_array_push(&cmcf->phases[NGX_HTTP_CONTENT_PHASE].handlers);
        if (h == NULL) {
                return NGX_ERROR;
        }

        *h = ngx_http_notetask_handler;

        return NGX_OK;
}
