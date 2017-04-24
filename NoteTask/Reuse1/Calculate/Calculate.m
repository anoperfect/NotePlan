




#define PRINTF(x...) //printf("[%d] -",__LINE__);printf(x)









static BOOL keable_kmdescripe = NO;

#define USE_MEMORY_CHECK    1
#define USE_MEMORY_POOL     1

#if USE_MEMORY_POOL

typedef struct  {
    
    long offset;
    long length;
    BOOL isFree;
    
}MemorySeg;



static MemorySeg ksegs[100];
static int ksegs_count = 0;
static void *kmv = NULL;


void kminit()
{
    if(!kmv) {
        size_t size = 1024*1024;
        kmv = malloc(size);
        ksegs[0].offset = 0;
        ksegs[0].length = size;
        ksegs[0].isFree = YES;
        ksegs_count = 1;
    }
}

void kmdescripe(const char *es)
{
    if(!keable_kmdescripe) return;
    
    PRINTF("------%s\n", es);

    PRINTF("\n\n");
}

void *malloc_d(size_t size, const char *function, int line)
{
    kminit();
    
    if(keable_kmdescripe) {
        PRINTF("alloc : %lld\n", pv);
    }
    
    void *p = NULL;
    
    for(NSInteger idx = 0; idx < ksegs_count; idx ++) {
        MemorySeg *seg = &ksegs[idx];
        if(seg->isFree && seg->length >= size) {
            p = kmv + seg->offset;
            if(seg->length == size) {
                seg->isFree = NO;
            }
            else {
                for(int idxMove = ksegs_count-1; idxMove>idx; idxMove--) {
                    ksegs[idxMove+1] = ksegs[idxMove];
                }
                ksegs[idx+1].offset = ksegs[idx].offset + size;
                ksegs[idx+1].length = ksegs[idx].length - size;
                ksegs[idx+1].isFree = YES;
                
                ksegs[idx].length = size;
                ksegs[idx].isFree = NO;
                
                ksegs_count ++;
            }
            
            break;
        }
    }
    
    assert(p);
    
    kmdescripe("after alloc");
    
    return p;
}


void free_d(void *p, const char *function, int line)
{//return;
    kmdescripe("\n\nbefore free");
    
    NSInteger idxFree = NSNotFound;
    for(NSInteger idx = 0; idx < ksegs_count; idx ++) {
        MemorySeg *seg = &ksegs[idx];
        if((kmv+seg->offset) == p && !seg->isFree) {
            idxFree = idx;
            break;
        }
    }
    
    assert(idxFree != NSNotFound);
    
    BOOL assemblePrev = (idxFree>0 && ksegs[idxFree-1].isFree);
    BOOL assembleNext = (idxFree < (ksegs_count-1) && ksegs[idxFree+1].isFree) ;
    if(assemblePrev && assembleNext) {
        ksegs[idxFree-1].length += (ksegs[idxFree].length + ksegs[idxFree+1].length);
        for(long idx=idxFree+2; idx<ksegs_count; idx++) {
            ksegs[idx-2] = ksegs[idx];
        }
        ksegs_count -= 2;
    }
    else if(assemblePrev) {
        ksegs[idxFree-1].length += (ksegs[idxFree].length);
        for(long idx=idxFree+1; idx<ksegs_count; idx++) {
            ksegs[idx-1] = ksegs[idx];
        }
        ksegs_count -= 1;
        
    }
    else if(assembleNext) {
        ksegs[idxFree].length += ksegs[idxFree+1].length;
        ksegs[idxFree].isFree = YES;
        for(long idx=idxFree+2; idx<ksegs_count; idx++) {
            ksegs[idx-1] = ksegs[idx];
        }
        ksegs_count -= 1;
    }
    else {
        ksegs[idxFree].isFree = YES;
    }
    
    kmdescripe("after free");
}


void kmcheck()
{
    
}

#else
NSMutableDictionary *kMemory = nil;


void kminit()
{
    if(!kMemory) {
        kMemory = [@{} mutableCopy];
    }
}

void kmdescripe(const char *es)
{
    if(!keable_kmdescripe) return;
    
    PRINTF("------%s\n", es);
    for(NSNumber *number in kMemory.allKeys) {
        unsigned long long pvtmp = [number unsignedLongLongValue];pvtmp=pvtmp;
        //        char *ptmp = (char*)pvtmp;
        PRINTF("%s", [NSString stringWithFormat:@"-       %lld : %s   %@\n", pvtmp, (char*)pvtmp, kMemory[number]].UTF8String);
    }
    PRINTF("\n\n");
}

void *malloc_d(size_t size, const char *function, int line)
{
    kminit();
    void *p = malloc (size);
    unsigned long long pv = (unsigned long long)p;
    if(keable_kmdescripe) {
        PRINTF("alloc : %lld\n", pv);
    }
    assert(kMemory[@(pv)] == nil);
    kMemory[@(pv)] = [NSString stringWithFormat:@"%s %d %llu", function, line, pv];
    //    kMemory[@(pv)] = @"1";
    
    kmdescripe("after alloc");
    
    return p;
}


void free_d(void *p, const char *function, int line)
{
    kmdescripe("\n\nbefore free");
    unsigned long long pv = (unsigned long long)p;
    NSString *s = kMemory[@(pv)];
    if([s isKindOfClass:[NSString class]]) {
        [kMemory removeObjectForKey:@(pv)];
    }
    else {
        if(keable_kmdescripe) {
            PRINTF("free %lld on %s <%d>.(%s)\n", pv, function, line, (char*)p);
        }
        NSLog(@"%@", kMemory);
        assert(0);
    }
    
    kmdescripe("after free");
    
    free (p);
}


void kmcheck()
{//return ;
    if(kMemory.count) {
        NSLog(@"%@", kMemory);
        NSArray *a = kMemory.allKeys;
        for(NSNumber *n in a) {
            NSString *s = kMemory[n];
            printf("///--- : %s\n", s.UTF8String);
            //            NSLog(@"%@", v[2]);
            unsigned long long pv = [n integerValue];
            char *p = (char*)pv;
            printf("%s\n", p);
        }
        
        assert(0);
    }
}



#endif


char *strdup_d(const char *s, const char *function, int line)
{
    kminit();
    size_t len = strlen(s);
    char *r = malloc_d(len+1, function, line);
    strcpy(r, s);
    
    //    char *r = strdup(s);
    //    unsigned long long pv = (unsigned long long)r;
    //    printf("\n\nalloc : %lld\n", pv);
    //    assert(kMemory[@(pv)] == nil);
    //    //    kMemory[@(pv)] = [NSString stringWithFormat:@"%s %d %llu", function, line, (unsigned long long)r];
    //    kMemory[@(pv)] = @"1";
    //
    //    kmdescripe("after strdup");
    
    return r;
}


char *strndup_d(const char *s, size_t n, const char *function, int line)
{
    kminit();
    //    char *r = strndup (s, n);
    //    unsigned long long pv = (unsigned long long)r;
    //    assert(kMemory[@(pv)] == nil);
    //    //    kMemory[@(pv)] = [NSString stringWithFormat:@"%s %d %llu", function, line, (unsigned long long)r];
    //    kMemory[@(pv)] = @"1";
    //
    //    printf("\n\nalloc : %lld\n", pv);
    //    kmdescripe("after strndup");
    
    size_t len = MIN(n, strlen(s));
    char *r = malloc_d(len+1, function, line);
    strncpy(r, s, len);
    r[len] = '\0';
    
    return r;
}



#if USE_MEMORY_CHECK

#define malloc_r(size) malloc_d(size, __FUNCTION__, __LINE__)
#define free_r(p) free_d(p, __FUNCTION__, __LINE__)
#define strdup_r(s) strdup_d(s, __FUNCTION__, __LINE__)
#define strndup_r(s, n) strndup_d(s, n, __FUNCTION__, __LINE__)

#else

#define malloc_r(size) malloc(size)
#define free_r(p) free(p)
#define strdup_r(s) strdup(s)
#define strndup_r(s, n) strndup(s, n)


#endif








typedef struct {
    
    char *decimal;
}
StringFloatExtend;


typedef struct {
    char *x;
    char *y;
}
StringDividExtend;



typedef enum {
    StringNumberTypeInvalid     = -1,
    StringNumberTypeInteger     = 0,
    StringNumberTypeDivid ,
    StringNumberTypeNull ,
}StringNumberType;


typedef struct {
    StringNumberType type;
    BOOL minus;
    char *integer;
    
    long idx;
    
    union {
        StringFloatExtend vfloat;
        StringDividExtend vdivid;
    }extend;
}
StringNumber;































void stringDigitClearIntegerLeft0(char **pps, long *plen)
{
    char *s = *pps;
    size_t len = *plen;
    
    long count0 = 0;
    char ch;
    long idx = 0;
    while (idx < len && '0' == (ch = s[idx]) && '\0' != ch) {
        count0 ++;
        idx ++;
    }
    
    if(count0 > 0) {
        for(idx = 0; idx < len - count0 + 1; idx ++) {
            s[idx] = s[idx + count0];
        }
        
        if(s[0] == '\0') {
            s[0] = '0';
            s[1] = '\0';
        }
    }
}


void stringDigitClearDecimalRight(char **pps, long *plen)
{
    char *s = *pps;
    size_t len = *plen;
    
    long count0 = 0;
    char ch;
    long idx = len-1;
    while (idx >= 0 && '0' == (ch = s[idx])) {
        count0 ++;
        idx --;
    }
    
    if(count0 > 0) {
        if(count0 == len) {
            free_r(*pps);
            *pps = NULL;
            *plen = 0;
        }
        else {
            s[len-count0] = '\0';
            *plen -= count0;
        }
    }
}


int stringDigitCompareInteger(const char* s1, size_t len1, const char* s2, size_t len2)
{
    if(len1 > len2) {
        return 1;
    }
    else if(len1 == len2) {
        return strcmp(s1, s2);
    }
    else {
        return -1;
    }
}


void stringDigitReuseSubInteger(char *a, const char *b)
{
    long len_a = strlen(a);
    long len_b = strlen(b);
    
    long idx = len_a - 1;
    for(idx = len_a - 1; idx >= 0; idx --) {
        if((idx-(len_a - len_b)) >= 0) {
            a[idx] -= (b[idx-(len_a - len_b)] - '0');
        }
        
        if(a[idx] < '0') {
            a[idx] += 10;
            a[idx - 1] -= 1;
        }
    }
    
    stringDigitClearIntegerLeft0(&a, &len_a);
}


void stringDigitReuseAddInteger(char *a, const char *b)
{
    long len_a = strlen(a);
    long len_b = strlen(b);
    
    long idx;
    if(len_a < len_b) {
        for(idx = len_b-1; idx>=0; idx --) {
            if(idx < (len_b - len_a)) {
                a[idx] = '0';
            }
            else {
                a[idx] = a[idx - (len_b - len_a)];
            }
        }
        a[len_b] = '\0';
        len_a = len_b;
    }
    
    for(idx = len_a - 1; idx >= 0; idx --) {
        if((idx-(len_a - len_b)) >= 0) {
            a[idx] += (b[idx-(len_a - len_b)] - '0');
        }
        
        if(a[idx] > '9') {
            a[idx] -= 10;
            if(idx > 0) {
                a[idx - 1] += 1;
            }
            else {
                for(idx = len_b; idx>0; idx --) {
                    a[idx] = a[idx - 1];
                }
                a[0] = '1';
                a[len_b + 1] = '\0';
            }
        }
    }
}



void stringDigitReuseIntegerAdd(char **ppa, const char *b)
{
    char *a = *ppa;
    long len_a = strlen(a);
    long len_b = strlen(b);
    
    if(len_a < len_b) {
        *ppa = malloc_r(len_b + 1);
        memset(*ppa, '0', len_b - len_a);
        strcpy((*ppa)+len_b-len_a, a);
        
        free_r(a);
        a = *ppa;
        len_a = len_b;
    }
    
    assert(len_a >= len_b);
    
    long diff = len_a - len_b;
    long idx ;
    BOOL carry = 0;
    for(idx = len_a - 1; idx >= 0; idx --) {
        long idx_b = idx - diff;
        
        if(idx_b >= 0) {
            a[idx] += (b[idx_b] - '0');
        }
        
        if(a[idx] > '9') {
            a[idx] -= 10;
            if(idx > 0) {
                a[idx-1] += 1;
            }
            else {
                carry = 1;
            }
        }
    }
    
    if(carry) {
        *ppa = malloc_r(len_a+2);
        *ppa[0] = '1';
        strcpy(*ppa+1, a);
        free_r(a);
    }
}



void stringDigitReuseMuiltiply10n(char *a, size_t size, long n)
{
    size_t len_a = strlen(a);
    if(size - 1 - len_a >= n) {
        long idx = 0;
        for(idx=0; idx<n;idx++) {
            a[len_a+idx] = '0';
        }
        
        a[len_a+idx] = '\0';
    }
    else {
        
        assert(0);
    }
}


char *stringDigitMuiltiply10n(const char *s, long n)
{
    long len = strlen(s);
    assert(len > 0);
    
    char *r = malloc_r(len + n + 1);
    memcpy(r, s, len);
    memset(r+len, '0', n);
    r[len+n] = '\0';
    
    return r;
}


char *stringDigitReuseDividGetInteger(char *x, const char *y)
{
    assert(y);
    assert(strcmp(y, "0"));
    
    PRINTF("stringDigitReuseDividGetInteger : [%s]/[%s]\n", x, y);
    
    char *integer;
    
    long len_x = strlen(x);
    long len_y = strlen(y);
    
    if(len_x>=len_y) {
        long len = len_x - len_y + 1;
        integer = malloc_r(len + 1);
        strcpy(integer, "0");
    }
    else {
        integer = strdup_r("0");
    }
    
    int cmp;
    int cmpLeft;
    size_t sizeTmpMuiltiply10 = len_x + 1;
    char *tmpMuiltiply10 = malloc_r(sizeTmpMuiltiply10);
    
    size_t sizeTmp10n = len_x + 1;
    char *tmp10n = malloc_r(sizeTmp10n);
    
    
    while (1) {
        len_x = strlen(x);
        cmp = stringDigitCompareInteger(x, len_x, y, len_y);
        if(cmp < 0) {
            break;
        }
        if(cmp == 0) {
            stringDigitReuseAddInteger(integer, "1");
            strcpy(x, "0");
            break;
        }
        else {
            cmpLeft = strcmp(x, y);
            if(cmpLeft > 0) {
                strcpy(tmpMuiltiply10, y);
                strcpy(tmp10n, "1");
                if(len_x > len_y) {
                    stringDigitReuseMuiltiply10n(tmpMuiltiply10, sizeTmpMuiltiply10, len_x - len_y);
                    stringDigitReuseMuiltiply10n(tmp10n, sizeTmp10n, len_x - len_y);
                }
                stringDigitReuseSubInteger(x, tmpMuiltiply10);
                stringDigitReuseAddInteger(integer, tmp10n);
            }
            else if(cmpLeft == 0) {
                assert(0);
            }
            else {
                strcpy(tmpMuiltiply10, y);
                strcpy(tmp10n, "1");
                if((len_x - len_y - 1) > 0) {
                    stringDigitReuseMuiltiply10n(tmpMuiltiply10, sizeTmpMuiltiply10, len_x - len_y - 1);
                    stringDigitReuseMuiltiply10n(tmp10n, sizeTmp10n, len_x - len_y - 1);
                }
                stringDigitReuseSubInteger(x, tmpMuiltiply10);
                stringDigitReuseAddInteger(integer, tmp10n);
            }
        }
    }
    
    free_r(tmp10n);
    free_r(tmpMuiltiply10);
    
    PRINTF("%s&%s/%s\n", integer, x, y);
    
    return integer;
}


void stringDigitReuseDividSimplify(char *x, char *y)
{
    if(NULL == x || NULL == y || 0 == strcmp(x, "0") || 0 == strcmp(y, "0")) {
        return;
    }
    
    char *xc = strdup_r(x);
    char *yc = strdup_r(y);
    
    char *r = NULL;
    
    while (1) {
        if(0 == strcmp(xc, yc)) {
            break;
        }
        
        char *integer = stringDigitReuseDividGetInteger(yc, xc);
        free_r(integer);
        if(strcmp(yc, "0") == 0) {
            r = xc;
            break;
        }
        else {
            char *tmp = xc;
            xc = yc;
            yc = tmp;
        }
    }
    
    if(0 == strcmp(r, "1")) {
        
    }
    else {
        
        char *xtmp = strdup_r(x);
        char *ytmp = strdup_r(y);
        
        char *xn = stringDigitReuseDividGetInteger(xtmp, r);
        char *yn = stringDigitReuseDividGetInteger(ytmp, r);
        
        free_r(xtmp);
        free_r(ytmp);
        
        strcpy(x, xn);
        strcpy(y, yn);
        
        free_r(xn);
        free_r(yn);
        
        
    }
    
    free_r(xc);
    free_r(yc);
}


char* stringNumberDescription(const StringNumber *n)
{
    char *s = nil;
    char *scopy = "";
    
    //    PRINTF("stringNumberDescription : integer : %p, idx : %ld\n", n->integer, n->idx);
    
    if(n->type == StringNumberTypeInteger) {
        size_t len = strlen(n->integer);
        size_t len_decimal = n->extend.vfloat.decimal!=nil?strlen(n->extend.vfloat.decimal):0;
        if(n->minus) {
            s = malloc_r(len+1 + 1 + len_decimal + 1);
            s[0] = '-';
            scopy = s + 1;
        }
        else {
            s = malloc_r(len + 1 + len_decimal +1);
            scopy = s;
        }
        
        memcpy(scopy, n->integer, len+1);
        scopy += len;
        
        if(len_decimal>0) {
            scopy[0] = '.';
            scopy ++;
            memcpy(scopy, n->extend.vfloat.decimal, len_decimal);
            scopy += len_decimal;
        }
        
        scopy[0] = '\0';
    }
    else if(n->type == StringNumberTypeDivid){
        size_t len = 1 + strlen(n->integer) + 1 + strlen(n->extend.vdivid.x) + 1 + strlen(n->extend.vdivid.y);
        size_t size = len + 1;
        s = malloc_r(len + 1);
        if(0 == strcmp(n->integer, "0")) {
            snprintf(s, size, "%s%s/%s", n->minus?"-":"", n->extend.vdivid.x, n->extend.vdivid.y);
        }
        else {
            snprintf(s, size, "%s%s&%s/%s", n->minus?"-":"", n->integer, n->extend.vdivid.x, n->extend.vdivid.y);
        }
    }
    else if(n->type == StringNumberTypeNull){
        s = strdup_r("null");
    }
    
    if(!s) {
        s = strdup_r("invalid");
    }
    return s;
}


char* stringNumberDebugDescription(const StringNumber *n)
{
    static char *ss[3] = {nil};
    if(!ss[0]) {
        ss[0] = malloc(1000000);
        ss[1] = malloc(1000000);
        ss[2] = malloc(1000000);
        
        static int idx = 0;
        idx ++;
        
        assert(idx == 1);
    }
    static int nss = 0;
    
    char *s = ss[nss];
    nss = (nss + 1)%3;
    char *scopy = s;
    
    //    PRINTF("stringNumberDescription : integer : %p, idx : %ld\n", n->integer, n->idx);
    
    if(n->type == StringNumberTypeInteger) {
        size_t len = strlen(n->integer);
        size_t len_decimal = n->extend.vfloat.decimal!=nil?strlen(n->extend.vfloat.decimal):0;
        if(n->minus) {
            s[0] = '-';
            scopy = s + 1;
        }
        else {
            scopy = s;
        }
        
        memcpy(scopy, n->integer, len+1);
        scopy += len;
        
        if(len_decimal>0) {
            scopy[0] = '.';
            scopy ++;
            memcpy(scopy, n->extend.vfloat.decimal, len_decimal);
            scopy += len_decimal;
        }
        
        scopy[0] = '\0';
    }
    else if(n->type == StringNumberTypeDivid){
        size_t len = 1 + strlen(n->integer) + 1 + strlen(n->extend.vdivid.x) + 1 + strlen(n->extend.vdivid.y);
        size_t size = len + 1;
        if(0 == strcmp(n->integer, "0")) {
            snprintf(s, size, "%s%s/%s", n->minus?"-":"", n->extend.vdivid.x, n->extend.vdivid.y);
        }
        else {
            snprintf(s, size, "%s%s&%s/%s", n->minus?"-":"", n->integer, n->extend.vdivid.x, n->extend.vdivid.y);
        }
    }
    else if(n->type == StringNumberTypeNull){
        strcpy(s, "null");
    }
    
    if(!s) {
        strcpy(s, "invalid");
    }
    return s;
}


void stringNumberIntegerToDivid(const StringNumber *nInteger, StringNumber *nDivid)
{
    
    nDivid->type = StringNumberTypeDivid;
    nDivid->minus = nInteger->minus;
    nDivid->integer = strdup_r(nInteger->integer);
    
    if(nInteger->extend.vfloat.decimal) {
        nDivid->extend.vdivid.x = strdup_r(nInteger->extend.vfloat.decimal);
        nDivid->extend.vdivid.y = stringDigitMuiltiply10n("1", strlen(nInteger->extend.vfloat.decimal));
    }
    else {
        nDivid->extend.vdivid.x = strdup_r("0");
        nDivid->extend.vdivid.y = strdup_r("1");
    }
}


void stringNumberReuseIntegerToDivid(StringNumber *n)
{
    PRINTF("stringNumberReuseIntegerToDivid (%s)\n", stringNumberDebugDescription(n));
    assert(n->type == StringNumberTypeInteger);
    if(n->extend.vfloat.decimal) {
        char *x = strdup_r(n->extend.vfloat.decimal);
        n->extend.vdivid.y = stringDigitMuiltiply10n("1", strlen(n->extend.vdivid.x));
        free_r(n->extend.vfloat.decimal);
        n->extend.vfloat.decimal = NULL;
        n->extend.vdivid.x = x;
    }
    else {
        n->extend.vdivid.x = strdup_r("0");
        n->extend.vdivid.y = strdup_r("1");
    }
    n->type = StringNumberTypeDivid;
    PRINTF("stringNumberReuseIntegerToDivid (%s)\n", stringNumberDebugDescription(n));
}


char *stringDigitAddInteger(const char* s1, const char* s2)
{
    long len1 = (int)strlen(s1);
    long len2 = (int)strlen(s2);
    
    if(len1 < len2) {
        long tmp = len1;
        len1 = len2;
        len2 = tmp;
        
        const char *sTmp = s1;
        s1 = s2;
        s2 = sTmp;
    }
    
    long len = len1 + 1; /* 进位. */
    long size = len + 1; /* 进位, 结束. */
    char *r = malloc_r(size);
    r[0] = '0';
    memcpy(r+1, s1, len1+1);
    
    long idx = 0;
    for(; idx < len2; idx ++) {
        r[len-1-idx] += s2[len2-1-idx] - '0';
        if(r[len-1-idx] > '9') {
            r[len-1-idx] -= 10;
            r[len-2-idx] += 1;
        }
    }
    
    for (idx=len1-len2; idx>0; idx--) {
        if(r[idx] > '9') {
            r[idx] -= 10;
            r[idx-1] += 1;
        }
    }
    
    stringDigitClearIntegerLeft0(&r, &len);
    
    return r;
}


char *stringDigitAddDecimal(const char* s1, const char* s2, BOOL *carry)
{
    *carry = NO;
    
    if(s1 == NULL && s2 == NULL) {
        return NULL;
    }
    else if(s1 != NULL && s2 == NULL) {
        char *s1copy = strdup_r(s1);
        return s1copy;
    }
    else if(s2 != NULL && s1 == NULL) {
        char *s2copy = strdup_r(s2);
        return s2copy;
    }
    
    long len1 = (int)strlen(s1);
    long len2 = (int)strlen(s2);
    
    
    if(len1 < len2) {
        long tmp = len1;
        len1 = len2;
        len2 = tmp;
        
        const char *sTmp = s1;
        s1 = s2;
        s2 = sTmp;
    }
    
    long len = len1; /* 进位. */
    long size = len + 1; /* 进位, 结束. */
    char *r = malloc_r(size);
    r[0] = '0';
    memcpy(r, s1, len1+1);
    
    long idx = 0;
    for(idx=len2-1; idx > 0; idx --) {
        r[idx] += s2[idx] - '0';
        if(r[idx] > '9') {
            r[idx] -= 10;
            r[idx-1] += 1;
        }
    }
    
    r[0] += (s2[0] - '0');
    if(r[0] > '9') {
        r[0] -= 10;
        *carry = YES;
    }
    
    stringDigitClearDecimalRight(&r, &len);
    
    return r;
}


int stringDigitCompareDecimal(const char* s1, const char* s2)
{
    if(s1 == NULL && s2 ==NULL) {
        return 0;
    }
    else if(s1 == NULL && s2 != NULL) {
        return -1;
    }
    else if(s1 != NULL && s2 == NULL) {
        return 1;
    }
    else {
        return strcmp(s1, s2);
    }
}


char *stringDigitConnect(const char *s1, const char *s2)
{
    if(s1 == NULL && s2 == NULL) {
        return NULL;
    }
    else if(s1 != NULL && s2 == NULL) {
        return strdup_r(s1);
    }
    else if(s1 == NULL && s2 != NULL) {
        return strdup_r(s2);
    }
    
    long len1 = (int)strlen(s1);
    long len2 = (int)strlen(s2);
    long len = len1 + len2;
    char *r = malloc_r(len + 1);
    r[len] = '\0';
    memcpy(r, s1, len1);
    memcpy(r+len1, s2, len2);
    
    stringDigitClearIntegerLeft0(&r, &len);
    
    return r;
}


void stringDigitSplitForDecimal(const char *s, long lenDecimal, char **ppinteger, char **ppdecimal)
{
    char *integer = NULL;
    char *decimal = NULL;
    
    if(lenDecimal == 0) {
        integer = strdup_r(s);
        decimal = NULL;
    }
    
    long len = strlen(s);
    if(len > lenDecimal) {
        integer = strndup_r(s, len-lenDecimal);
        decimal = strndup_r(s+(len-lenDecimal), lenDecimal);
    }
    else if(len == lenDecimal) {
        integer = strdup_r("0");
        decimal = strdup_r(s);
    }
    else {
        integer = strdup_r("0");
        decimal = malloc_r(lenDecimal + 1);
        memset(decimal, '0', lenDecimal - len);
        memcpy(decimal+lenDecimal-len, s, len+1);
    }
    
    *ppinteger = integer;
    *ppdecimal = decimal;
}


char *stringDigitMultiply(const char* s1, const char* s2)
{
    long len1 = (int)strlen(s1);
    long len2 = (int)strlen(s2);
    
    if(len1 < len2 || (len1 == len2 && strcmp(s1, s2) < 0)) {
        long tmp = len1;
        len1 = len2;
        len2 = tmp;
        
        const char *sTmp = s1;
        s1 = s2;
        s2 = sTmp;
    }
    
    long len = len1 + len2;
    long size = len + 1;
    char *r = malloc_r(size);
    r[size-1] = '\0';
    memset(r, 0, len);
    
    long idx2 = 0;
    long idx1 = 0;
    for(idx2 = 0; idx2 < len2; idx2 ++)
        for(idx1 = 0; idx1 < len1; idx1 ++) {
            r[len-1-idx1-idx2] += (s2[len2-1-idx2] - '0') * (s1[len1-1-idx1] - '0');
            if(r[len-1-idx1-idx2] >= 10) {
                r[len-1-idx1-idx2-1] += r[len-1-idx1-idx2] / 10;
                r[len-1-idx1-idx2] = r[len-1-idx1-idx2] % 10;
            }
        }
    
    /* 各字符加上s1*s2对应值后可能溢出, 因此不能使用+-法中的'0'基础值. */
    long idx;
    for(idx = 0; idx < len; idx ++) {
        r[idx] += '0';
    }
    
    stringDigitClearIntegerLeft0(&r, &len);
    
    return r;
}


typedef struct {
    long loc;
    long length;
}StringRange;


long _stringPrefixBlankCount(const char *s)
{
    long count = 0;
    while (*s != '\0' && (*s == ' ' || *s == '\t')) {
        count ++;
        s ++;
    }
    
    return count;
}


char *_stringReplaceRange(const char *s, StringRange range, const char *to)
{
    char *r;
    long len = strlen(s) - range.length + strlen(to);
    r = malloc_r(len + 1);
    
    memcpy(r, s, range.loc);
    memcpy(r+range.loc, to, strlen(to));
    memcpy(r+range.loc+strlen(to), s+range.loc+range.length, strlen(s)-range.loc-range.length);
    r[len] = '\0';
    
    return r;
}


BOOL _stringCharIsOp(char ch)
{
    return (ch == '+' || ch == '-' || ch == '*' || ch == '/');
}


int StringNumberCompareIngoreMinus(const StringNumber *const n1, const StringNumber *const n2)
{
    int ret = 0;
    
    int cmpInteger = stringDigitCompareInteger(n1->integer, strlen(n1->integer), n2->integer, strlen(n2->integer));
    if(cmpInteger > 0) {
        ret = 1;
    }
    else if(cmpInteger < 0) {
        ret = -1;
    }
    else {
        //整数部分相同.
        if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeInteger) {
            ret = stringDigitCompareDecimal(n1->extend.vfloat.decimal, n2->extend.vfloat.decimal);
            
        }
        else {
            assert(0);
        }
    }

    return ret;
}


char *stringDigitSubInteger(const char* s1, const char* s2, BOOL *minus)
{
    if(minus) {
        *minus = 0;
    }
    
    long len1 = (int)strlen(s1);
    long len2 = (int)strlen(s2);
    
    if(stringDigitCompareInteger(s1, len1, s2, len2) < 0) {
        long tmp = len1;
        len1 = len2;
        len2 = tmp;
        
        const char *sTmp = s1;
        s1 = s2;
        s2 = sTmp;
        
        if(minus) {
            *minus = 1;
        }
        else {
            assert(0);
        }
    }
    
    //    long size = len1 + 1;
    char *r = strdup_r(s1);
    
    long idx = 0;
    for(idx = len1 - 1; idx >= len1 - len2; idx --) {
        r[idx] -= s2[idx-(len1-len2)] - '0';
        if(r[idx] < '0') {
            r[idx] += 10;
            r[idx-1] -= 1;
        }
    }
    
    for(idx = len1-len2-1; idx>0; idx --) {
        if(r[idx] < '0') {
            r[idx] += 10;
            r[idx-1] -= 1;
        }
        else {
            break;
        }
    }
    
    stringDigitClearIntegerLeft0(&r, &len1);
    
    return r;
}


char *stringDigitSubDecimal(const char* s1, const char* s2, BOOL *subInteger)
{
    *subInteger = NO;
    if(s1 == NULL && s2 == NULL) {
        return NULL;
    }
    else if(s1 != NULL && s2 == NULL) {
        return strdup_r(s1);
    }
    else if(s1 == NULL && s2 != NULL) {
        *subInteger = YES;
        long len = strlen(s2);
        char *r = malloc_r(len + 1);
        r[len] = '\0';
        long idx = 0;
        for(idx = 0; idx < len; idx++) {
            if(idx == len-1) {
                r[idx] = 10 - (s2[idx] - '0') + '0';
            }
            else {
                r[idx] = 9 - (s2[idx] - '0') + '0';
            }
        }
        
        return r;
    }
    
    long len1 = (int)strlen(s1);
    long len2 = (int)strlen(s2);
    long len ;
    char *r;
    long idx = 0;
    
    if(len1 > len2) {
        len = len1;
        r = malloc_r(len+1);
        memcpy(r, s1, len+1);
        for(idx=len2-1; idx>=0; idx--) {
            r[idx] -= (s2[idx]-'0');
            if(r[idx] < '0') {
                r[idx] += 10;
                if(idx == 0) {
                    *subInteger = 1;
                }
                else {
                    r[idx-1] -= 1;
                }
            }
        }
    }
    else {
        len = len2;
        r = malloc_r(len+1);
        memcpy(r, s1, len1);
        memset(r+len1, '0', len2-len1);
        r[len] = '\0';
        
        for(idx=len-1; idx>=0; idx--) {
            r[idx] -= (s2[idx]-'0');
            if(r[idx] < '0') {
                r[idx] += 10;
                if(idx == 0) {
                    *subInteger = 1;
                }
                else {
                    r[idx-1] -= 1;
                }
            }
        }
    }
    
    stringDigitClearDecimalRight(&r, &len);
    
    return r;
}






void stringNumberSimplify(StringNumber *n)
{
    PRINTF("stringNumberSimplify : %s\n", stringNumberDebugDescription(n));
    
    if(n->type == StringNumberTypeDivid) {
        if(strcmp(n->extend.vdivid.x, "0") == 0) {
            free_r(n->extend.vdivid.x);
            free_r(n->extend.vdivid.y);
            
            n->type = StringNumberTypeInteger;
            n->extend.vfloat.decimal = NULL;
            
            if(n->minus && 0 == strcmp(n->integer, "0")) {
                n->minus = 0;
            }
        }
        else {
            stringDigitReuseDividSimplify(n->extend.vdivid.x, n->extend.vdivid.y);
        }
    }
    else if(n->type == StringNumberTypeInteger) {
        if(n->minus && 0 == strcmp(n->integer, "0") && n->extend.vfloat.decimal == NULL) {
            n->minus = 0;
        }
    }
}




void stringNumberFree(StringNumber *n)
{
#if 0
    printf("stringNumberFree<%p> : ", n);
    
    if(n->integer) {
        printf("%lld ", (unsigned long long)n->integer);
    }
    
    if(n->type == StringNumberTypeInteger) {
        if(n->extend.vfloat.decimal) {
            printf("%lld ", (unsigned long long)n->extend.vfloat.decimal);
        }
    }
    else if (n->type == StringNumberTypeDivid) {
        if(n->extend.vdivid.x) {
            printf("%lld ", (unsigned long long)n->extend.vdivid.x);
        }
        
        if(n->extend.vdivid.y) {
            printf("%lld ", (unsigned long long)n->extend.vdivid.y);
        }
    }
    else {
        assert(0);
    }
    printf("\n");
#endif
    
    
    
    n->minus = 0;
    if(n->integer) {
        free_r(n->integer);
        n->integer = NULL;
    }
    
    if(n->type == StringNumberTypeInteger) {
        if(n->extend.vfloat.decimal) {
            free_r(n->extend.vfloat.decimal);
            n->extend.vfloat.decimal = NULL;
        }
    }
    else if (n->type == StringNumberTypeDivid) {
        if(n->extend.vdivid.x) {
            free_r(n->extend.vdivid.x);
            n->extend.vdivid.x = NULL;
        }
        
        if(n->extend.vdivid.y) {
            free_r(n->extend.vdivid.y);
            n->extend.vdivid.y = NULL;
        }
    }
    else {
        assert(0);
    }
    n->type = StringNumberTypeNull;
}


void stringNumberClear(StringNumber *n)
{
    memset(n, 0, sizeof(StringNumber));
}


void stringNumberAssignNewValue(StringNumber *n, StringNumber *new)
{
    stringNumberFree(n);
    *n = *new;
    stringNumberClear(new);
}


void _stringNumberAssginFromInteger(StringNumber *n, long long int integer)
{
    n->type = StringNumberTypeInteger;
    if(integer >= 0) {
        n->minus = 0;
    }
    else {
        n->minus = 1;
        integer = -integer;
    }
    n->integer = malloc_r(100);
    snprintf(n->integer, 100, "%lld", integer);
    n->extend.vfloat.decimal = NULL;
}





void stringDigitDividAdd(const char *x1, const char *y1, const char *x2, const char *y2, char **ppx, char **ppy, BOOL *carry)
{
    *carry = 0;
    char *y = stringDigitMultiply(y1, y2);
    
    char *x1y2 = stringDigitMultiply(x1, y2);
    char *x2y1 = stringDigitMultiply(x2, y1);
    char *x = stringDigitAddInteger(x1y2, x2y1);
    
    free_r(x1y2);
    free_r(x2y1);
    
    int cmp = stringDigitCompareInteger(x, strlen(x), y, strlen(y));
    if(cmp >= 0) {
        *carry = 1;
        stringDigitReuseSubInteger(x, y);
    }
    
    stringDigitReuseDividSimplify(x, y);
    
    *ppx = x;
    *ppy = y;
    
    PRINTF("%s/%s + %s/%s = %s/%s\n", x1, y1, x2, y2, *ppx, *ppy);
}


void stringDigitDividSub(const char *x1, const char *y1, const char *x2, const char *y2, char **ppx, char **ppy, BOOL *minus)
{
    *minus = 0;
    char *y = stringDigitMultiply(y1, y2);
    
    char *x1y2 = stringDigitMultiply(x1, y2);
    char *x2y1 = stringDigitMultiply(x2, y1);
    char *x = stringDigitSubInteger(x1y2, x2y1, minus);
    
    free_r(x1y2);
    free_r(x2y1);
    
    stringDigitReuseDividSimplify(x, y);
    
    PRINTF("111 : %s/%s - %s/%s = %s/%s\n", x1, y1, x2, y2, x, y);
    
    *ppx = x;
    *ppy = y;
}



















void _stringNumberDebug(const StringNumber* n1)
{//return;
    PRINTF("---stringNumberDebug---%p\n", n1);
    switch (n1->type) {
        case StringNumberTypeInteger:
            PRINTF("%s integer: %lld [%s], decimal : %p [%s]\n", n1->minus?"-":" ", (unsigned long long)(n1->integer), n1->integer, n1->extend.vfloat.decimal, n1->extend.vfloat.decimal);
            break;
            
        case StringNumberTypeDivid:
            PRINTF("%s integer: %lld [%s], x : %p [%s], y : %p [%s]\n", n1->minus?"-":" ", (unsigned long long)(n1->integer), n1->integer, n1->extend.vdivid.x, n1->extend.vdivid.x, n1->extend.vdivid.y, n1->extend.vdivid.y);
            break;
            
        default:
            assert(0);
            break;
    }
    PRINTF("---stringNumberDebug----------------------\n\n");
}






int _stringNumberDeepCopy(StringNumber *dest, StringNumber *src)
{
    int ret = 0;
    
    dest->type = src->type;
    dest->minus = src->minus;
    dest->integer = strdup_r(src->integer);
    dest->extend.vfloat.decimal = NULL;
    dest->extend.vdivid.x = NULL;
    dest->extend.vdivid.y = NULL;
    
    if(src->type == StringNumberTypeInteger) {
        dest->extend.vfloat.decimal = src->extend.vfloat.decimal?strdup_r(src->extend.vfloat.decimal):NULL;
    }
    else if(src->type == StringNumberTypeDivid) {
        dest->extend.vdivid.x = src->extend.vdivid.x?strdup_r(src->extend.vdivid.x):NULL;
        dest->extend.vdivid.y = src->extend.vdivid.y?strdup_r(src->extend.vdivid.y):NULL;
    }
    
    return ret;
}




int _stringNumberReuseSub(StringNumber* n1, StringNumber* n2) {return 0;}
int _stringNumberReuseMultiply(StringNumber* n1, StringNumber* n2) {return 0;}
int _stringNumberReuseDivid(StringNumber* n1, StringNumber* n2) {return 0;}

int _stringNumberReuseSwap(StringNumber* n1, StringNumber* n2)
{
    int ret = 0;
    
    StringNumber nTmp = *n1;
    *n1 = *n2;
    *n2 = nTmp;
    
    return ret;
}






































int stringDigitQuotient(const char *a, const char *b, char *tmp)
{
    int retn = 0;
    
    long len_a = strlen(a);
    
    strcpy(tmp, b);
    for(retn = 1; retn < 10; retn ++) {
        int cmp = stringDigitCompareInteger(a, len_a, tmp, strlen(tmp));
        
        if(cmp > 0) {
            stringDigitReuseAddInteger(tmp, b);
            continue;
        }
        else if(cmp == 0) {
            break;
        }
        else {
            retn --;
            break;
        }
    }
    
    retn = retn>9?9:retn;
    
    return retn;
}








int _stringNumberNoneMinusAdd(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    int ret = 0;
    
    n->type = StringNumberTypeInvalid;
    n->minus = NO;
    
    _stringNumberDebug(n1);
    _stringNumberDebug(n2);
    
    if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeInteger) {
        n->type = StringNumberTypeInteger;
        n->integer = stringDigitAddInteger(n1->integer, n2->integer);
        BOOL carry = NO;
        n->extend.vfloat.decimal = stringDigitAddDecimal(n1->extend.vfloat.decimal, n2->extend.vfloat.decimal, &carry);
        if(carry) {
            char *t = stringDigitAddInteger(n->integer, "1");
            free_r(n->integer);
            n->integer = t;
        }
    }
    else if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeDivid) {
        if(n1->extend.vfloat.decimal == NULL) {
            n->type = StringNumberTypeDivid;
            n->integer = stringDigitAddInteger(n1->integer, n2->integer);
            n->extend.vdivid.x = strdup_r(n2->extend.vdivid.x);
            n->extend.vdivid.y = strdup_r(n2->extend.vdivid.y);
        }
        else {
            StringNumber n1ToDivid;
            stringNumberIntegerToDivid(n1, &n1ToDivid);
            ret = _stringNumberNoneMinusAdd(&n1ToDivid, n2, n);
            stringNumberFree(&n1ToDivid);
        }
    }
    else if(n1->type == StringNumberTypeDivid && n2->type == StringNumberTypeInteger) {
        ret = _stringNumberNoneMinusAdd(n2, n1, n);
    }
    else {
        n->type = StringNumberTypeDivid;
        
        n->integer = stringDigitAddInteger(n1->integer, n2->integer);
        BOOL carry = 0;
        stringDigitDividAdd(n1->extend.vdivid.x, n1->extend.vdivid.y, n2->extend.vdivid.x, n2->extend.vdivid.y, &n->extend.vdivid.x, &n->extend.vdivid.y, &carry);
        if(carry) {
            char *tmp = stringDigitAddInteger(n->integer, "1");
            free_r(n->integer);
            n->integer = tmp;
        }
    }
    
    assert(n->type != StringNumberTypeInvalid);
    
    stringNumberSimplify(n);
    
    return ret;
}


int _stringNumberNoneMinusReuseAdd(StringNumber *n1, StringNumber *n2)
{
    int ret = 0;
    
    _stringNumberDebug(n1);
    _stringNumberDebug(n2);
    
    if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeInteger) {
        stringDigitReuseIntegerAdd(&n1->integer, n2->integer);
        BOOL carry = NO;
        
        char *decimal = stringDigitAddDecimal(n1->extend.vfloat.decimal, n2->extend.vfloat.decimal, &carry);
        if(n1->extend.vfloat.decimal) {
            free_r(n1->extend.vfloat.decimal);
        }
        n1->extend.vfloat.decimal = decimal;
        
        if(carry) {
            stringDigitReuseIntegerAdd(&n1->integer, "1");
        }
    }
    else if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeDivid) {
        if(n1->extend.vfloat.decimal == NULL) {
            n1->type = StringNumberTypeDivid;
            stringDigitReuseIntegerAdd(&n1->integer, n2->integer);
            n1->extend.vdivid.x = strdup_r(n2->extend.vdivid.x);
            n1->extend.vdivid.y = strdup_r(n2->extend.vdivid.y);
        }
        else {
            stringNumberReuseIntegerToDivid(n1);
            ret = _stringNumberNoneMinusReuseAdd(n1, n2);
        }
    }
    else if(n1->type == StringNumberTypeDivid && n2->type == StringNumberTypeInteger) {
        if(n2->extend.vfloat.decimal == NULL) {
            stringDigitReuseIntegerAdd(&n1->integer, n2->integer);
        }
        else {
            stringNumberReuseIntegerToDivid(n2);
            ret = _stringNumberNoneMinusReuseAdd(n1, n2);
        }
    }
    else {
        n1->type = StringNumberTypeDivid;
        stringDigitReuseIntegerAdd(&n1->integer, n2->integer);
        
        BOOL carry = 0;
        char *x ;
        char *y ;
        
        stringDigitDividAdd(n1->extend.vdivid.x, n1->extend.vdivid.y, n2->extend.vdivid.x, n2->extend.vdivid.y, &x, &y, &carry);
        if(carry) {
            stringDigitReuseIntegerAdd(&n1->integer, "1");
        }
        
        PRINTF("x=%s, y=%s\n", x, y);
        
        PRINTF("x=%s, y=%s\n", n1->extend.vdivid.x, n1->extend.vdivid.y);
        
        free_r(n1->extend.vdivid.x);
        free_r(n1->extend.vdivid.y);
        n1->extend.vdivid.x = x;
        n1->extend.vdivid.y = y;
        
        PRINTF("x=%s, y=%s\n", n1->extend.vdivid.x, n1->extend.vdivid.y);
        
        
        PRINTF("[%s]\n", stringNumberDebugDescription(n1));
    }
    
    assert(n1->type != StringNumberTypeInvalid);
    stringNumberSimplify(n1);
    
    if(n2->type != StringNumberTypeNull) {
        stringNumberFree(n2);
    }
    
    return ret;
}


int stringNumberNoneMinusAdd(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    return _stringNumberNoneMinusAdd(n1, n2, n);
}


int stringNumberNoneMinusReuseAdd(StringNumber *n1, StringNumber *n2)
{
    return _stringNumberNoneMinusReuseAdd(n1, n2);
}


int _stringNumberNoneMinusSub(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    int ret = 0;
    
    n->type = StringNumberTypeInvalid;
    n->minus = NO;
    
    if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeInteger) {
        n->type = StringNumberTypeInteger;
        /* 比较. */
        int cmp = StringNumberCompareIngoreMinus(n1, n2);
        if(0 == cmp) {
            n->minus = 0;
            n->integer = strdup_r("0");
            n->extend.vfloat.decimal = NULL;
        }
        else if(cmp > 0) {
            BOOL minus = 0;
            n->integer = stringDigitSubInteger(n1->integer, n2->integer, &minus);
            BOOL subInteger = 0;
            n->extend.vfloat.decimal = stringDigitSubDecimal(n1->extend.vfloat.decimal, n2->extend.vfloat.decimal, &subInteger);
            if(subInteger) {
                char *tmp = stringDigitSubInteger(n->integer, "1", &minus);
                free_r(n->integer);
                n->integer = tmp;
            }
        }
        else {
            n->minus = 1;
            BOOL minus = 0;
            n->integer = stringDigitSubInteger(n2->integer, n1->integer, &minus);
            BOOL subInteger = 0;
            n->extend.vfloat.decimal = stringDigitSubDecimal(n2->extend.vfloat.decimal, n1->extend.vfloat.decimal, &subInteger);
            if(subInteger) {
                char *tmp = stringDigitSubInteger(n->integer, "1", &minus);
                free_r(n->integer);
                n->integer = tmp;
            }
        }
    }
    else if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeDivid) {
        if(NULL == n1->extend.vfloat.decimal) {
            BOOL minus = 0;
            char *integer = stringDigitSubInteger(n1->integer, n2->integer, &minus);
            if(!minus) {
                if(0 == strcmp(integer, "0")) {
                    n->type = StringNumberTypeDivid;
                    n->minus = 1;
                    n->integer = strdup_r("0");
                    n->extend.vdivid.x = strdup_r(n2->extend.vdivid.x);
                    n->extend.vdivid.y = strdup_r(n2->extend.vdivid.y);
                    free_r(integer);
                }
                else {
                    stringDigitReuseSubInteger(integer, "1");
                    n->type = StringNumberTypeDivid;
                    n->minus = 0;
                    n->integer = integer;
                    n->extend.vdivid.x = stringDigitSubInteger(n2->extend.vdivid.y, n2->extend.vdivid.x, NULL);
                    n->extend.vdivid.y = strdup_r(n2->extend.vdivid.y);
                }
            }
            else {
                n->type = StringNumberTypeDivid;
                n->minus = 1;
                n->integer = integer;
                n->extend.vdivid.x = strdup_r(n2->extend.vdivid.x);
                n->extend.vdivid.y = strdup_r(n2->extend.vdivid.y);
            }
        }
        else {
            StringNumber n1ToDivid;
            stringNumberIntegerToDivid(n1, &n1ToDivid);
            ret = _stringNumberNoneMinusSub(&n1ToDivid, n2, n);
            stringNumberFree(&n1ToDivid);
        }
    }
    else if(n1->type == StringNumberTypeDivid && n2->type == StringNumberTypeInteger) {
        StringNumber n2ToDivid;
        stringNumberIntegerToDivid(n2, &n2ToDivid);
        ret = _stringNumberNoneMinusSub(n1, &n2ToDivid, n);
        stringNumberFree(&n2ToDivid);
    }
    else {
        n->type = StringNumberTypeDivid;
        
        const char *integer1;
        const char *x1;
        const char *y1;
        
        const char *integer2;
        const char *x2;
        const char *y2;
        
        integer1 = n1->integer;
        x1 = n1->extend.vdivid.x;
        y1 = n1->extend.vdivid.y;
        
        integer2 = n2->integer;
        x2 = n2->extend.vdivid.x;
        y2 = n2->extend.vdivid.y;
        
        BOOL integerMinus;
        char *integer = stringDigitSubInteger(integer1, integer2, &integerMinus);
        
        char *x;
        char *y;
        BOOL dividMinus;
        
        stringDigitDividSub(x1, y1, x2, y2, &x, &y, &dividMinus);
        
        if(integerMinus == dividMinus) {
            
            n->minus = integerMinus;
            n->integer = integer;
            n->extend.vdivid.x = x;
            n->extend.vdivid.y = y;
            
            PRINTF("ccc : %d\n", __LINE__);
        }
        else if(dividMinus) {
            if(0 == strcmp(integer, "0")) {
                PRINTF("ccc : %d\n", __LINE__);
                n->minus = 1;
                n->integer = integer;
                n->extend.vdivid.x = x;
                n->extend.vdivid.y = y;
            }
            else {
                PRINTF("ccc : %d\n", __LINE__);
                n->minus = 0;
                stringDigitReuseSubInteger(integer, "1");
                n->integer = integer;
                BOOL minus;
                n->extend.vdivid.x = stringDigitSubInteger(y, x, &minus);
                free_r(x);
                n->extend.vdivid.y = y;
            }
        }
        else {
            n->minus = 1;
            stringDigitReuseSubInteger(integer, "1");
            n->integer = integer;
            BOOL minus;
            n->extend.vdivid.x = stringDigitSubInteger(y, x, &minus);
            free_r(x);
            n->extend.vdivid.y = y;
            PRINTF("ccc : %d\n", __LINE__);
        }
    }
    
    PRINTF("ccc : %s\n", stringNumberDebugDescription(&n));
    
    stringNumberSimplify(n);
    
    PRINTF("ccc : %s\n", stringNumberDebugDescription(&n));
    
    return ret;
}


int _stringNumberNoneMinusReuseSub(StringNumber *n1, StringNumber *n2)
{
    int ret = 0;
    
    StringNumber n;
    ret = _stringNumberNoneMinusSub(n1, n2, &n);
    stringNumberFree(n2);
    stringNumberAssignNewValue(n1, &n);
    
    return ret;
}


int stringNumberNoneMinusSub(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    return _stringNumberNoneMinusSub(n1, n2, n);
}


int stringNumberNoneMinusReuseSub(StringNumber *n1, StringNumber *n2)
{
    return _stringNumberNoneMinusReuseSub(n1, n2);
}


int _stringNumberNoneMinusMultiply(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    int ret = 0;
    
    n->type = StringNumberTypeInvalid;
    n->minus = NO;
    
    if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeInteger) {
        n->type = StringNumberTypeInteger;

        
        if(NULL == n1->extend.vfloat.decimal && NULL == n2->extend.vfloat.decimal) {
            n->integer = stringDigitMultiply(n1->integer, n2->integer);
            n->extend.vfloat.decimal = NULL;
        }
        else {
            long lenDecimal = 0;
            if(n1->extend.vfloat.decimal) {
                lenDecimal += strlen(n1->extend.vfloat.decimal);
            }
            if(n2->extend.vfloat.decimal) {
                lenDecimal += strlen(n2->extend.vfloat.decimal);
            }
            
            char *s1connect = stringDigitConnect(n1->integer, n1->extend.vfloat.decimal);
            char *s2connect = stringDigitConnect(n2->integer, n2->extend.vfloat.decimal);
            
            char *resultBeforeDecimal = stringDigitMultiply(s1connect, s2connect);
            stringDigitSplitForDecimal(resultBeforeDecimal, lenDecimal, &n->integer, &n->extend.vfloat.decimal);
            long lenDecimalRe = strlen(n->extend.vfloat.decimal);
            stringDigitClearDecimalRight(&n->extend.vfloat.decimal, &lenDecimalRe);
            
            free_r(s1connect);
            free_r(s2connect);
            free_r(resultBeforeDecimal);
        }
    }
    else if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeDivid){
        StringNumber nDivid;
        stringNumberIntegerToDivid(n1, &nDivid);
        ret = _stringNumberNoneMinusMultiply(&nDivid, n2, n);
        stringNumberFree(&nDivid);
    }
    else if(n1->type == StringNumberTypeDivid && n2->type == StringNumberTypeInteger){
        ret = _stringNumberNoneMinusMultiply(n2, n1, n);
    }
    else {
        /* divid * divid. */
        n->type = StringNumberTypeDivid;
        
        char *a1y1 = stringDigitMultiply(n1->integer, n1->extend.vdivid.y);
        char *a1y1_x1 = stringDigitAddInteger(a1y1, n1->extend.vdivid.x);
        
        char *a2y2 = stringDigitMultiply(n2->integer, n2->extend.vdivid.y);
        char *a2y2_x2 = stringDigitAddInteger(a2y2, n2->extend.vdivid.x);
        
        char *x = stringDigitMultiply(a1y1_x1, a2y2_x2);
        char *y = stringDigitMultiply(n1->extend.vdivid.y, n2->extend.vdivid.y);
        
        n->integer = stringDigitReuseDividGetInteger(x, y);
        
        free_r(a1y1);
        free_r(a1y1_x1);
        free_r(a2y2);
        free_r(a2y2_x2);
        
        n->extend.vdivid.x = x;
        n->extend.vdivid.y = y;
    }
    
    stringNumberSimplify(n);
    return ret;
}


int _stringNumberNoneMinusReuseMultiply(StringNumber *n1, StringNumber *n2)
{
    int ret = 0;
    
    StringNumber n;
    ret = _stringNumberNoneMinusMultiply(n1, n2, &n);
    stringNumberFree(n2);
    stringNumberAssignNewValue(n1, &n);
    
    return ret;
}


int stringNumberNoneMinusMultiply(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    return _stringNumberNoneMinusMultiply(n1, n2, n);
}


int stringNumberNoneMinusReuseMultiply(StringNumber *n1, StringNumber *n2)
{
    return _stringNumberNoneMinusReuseMultiply(n1, n2);
}


int _stringNumberNoneMinusDivid(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    int ret = 0;
    
    n->type = StringNumberTypeInvalid;
    n->minus = NO;
    
    if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeInteger) {
        n->type = StringNumberTypeInteger;
        
        long lenDecimal = 0;
        long lenDecimal1 = n1->extend.vfloat.decimal?strlen(n1->extend.vfloat.decimal):0;
        long lenDecimal2 = n2->extend.vfloat.decimal?strlen(n2->extend.vfloat.decimal):0;
        
        if(n1->extend.vfloat.decimal) {
            lenDecimal += lenDecimal1;
        }
        if(n2->extend.vfloat.decimal) {
            lenDecimal += lenDecimal2;
        }
        
        char *s1connect = stringDigitConnect(n1->integer, n1->extend.vfloat.decimal);
        char *s2connect = stringDigitConnect(n2->integer, n2->extend.vfloat.decimal);
        
        if(lenDecimal1 == lenDecimal2) {
            
            
        }
        else if(lenDecimal1>lenDecimal2) {
            char *tmp = stringDigitMuiltiply10n(s2connect, lenDecimal1-lenDecimal2);
            free_r(s2connect);
            s2connect = tmp;
        }
        else {
            char *tmp = stringDigitMuiltiply10n(s1connect, lenDecimal2-lenDecimal1);
            free_r(s1connect);
            s1connect = tmp;
        }
        
        char *s1counting = strdup_r(s1connect);
        char *integer = stringDigitReuseDividGetInteger(s1counting, s2connect);
        if(0 == strcmp(s1counting, "0")) {
            n->type = StringNumberTypeInteger;
            n->integer = integer;
            n->extend.vfloat.decimal = NULL;
        }
        else {
            n->type = StringNumberTypeDivid;
            n->integer = integer;
            n->extend.vdivid.x = strdup_r(s1counting);
            n->extend.vdivid.y = strdup_r(s2connect);
        }
        
        free_r(s1counting);
        free_r(s1connect);
        free_r(s2connect);
    }
    else if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeDivid){
        StringNumber nDivid;
        stringNumberIntegerToDivid(n1, &nDivid);
        ret = _stringNumberNoneMinusDivid(&nDivid, n2, n);
        stringNumberFree(&nDivid);
    }
    else if(n1->type == StringNumberTypeDivid && n2->type == StringNumberTypeInteger){
        StringNumber nDivid;
        stringNumberIntegerToDivid(n2, &nDivid);
        ret = _stringNumberNoneMinusDivid(n1, &nDivid, n);
        stringNumberFree(&nDivid);
    }
    else {
        /* divid / divid. */
        n->type = StringNumberTypeDivid;
        
        char *a1y1 = stringDigitMultiply(n1->integer, n1->extend.vdivid.y);
        char *a1y1_x1 = stringDigitAddInteger(a1y1, n1->extend.vdivid.x);
        
        char *a2y2 = stringDigitMultiply(n2->integer, n2->extend.vdivid.y);
        char *a2y2_x2 = stringDigitAddInteger(a2y2, n2->extend.vdivid.x);
        
        char *x = stringDigitMultiply(a1y1_x1, n2->extend.vdivid.y);
        char *y = stringDigitMultiply(n1->extend.vdivid.y, a2y2_x2);
        
        n->integer = stringDigitReuseDividGetInteger(x, y);
        
        free_r(a1y1);
        free_r(a1y1_x1);
        free_r(a2y2);
        free_r(a2y2_x2);
        
        n->extend.vdivid.x = x;
        n->extend.vdivid.y = y;
        
        PRINTF("x=%s, y=%s\n", x, y);
        
    }
    
    stringNumberSimplify(n);
    return ret;
}


int _stringNumberNoneMinusReuseDivid(StringNumber *n1, StringNumber *n2)
{
    int ret = 0;
    
    StringNumber n;
    ret = _stringNumberNoneMinusDivid(n1, n2, &n);
    stringNumberFree(n2);
    stringNumberAssignNewValue(n1, &n);
    
    return ret;
}


int stringNumberNoneMinusDivid(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    return _stringNumberNoneMinusDivid(n1, n2, n);
}


int stringNumberNoneMinusReuseDivid(StringNumber *n1, StringNumber *n2)
{
    return _stringNumberNoneMinusReuseDivid(n1, n2);
}









void stringDigitDividToQuotient(const char *a, const char *b, char *result, size_t size)
{
    long len_a = strlen(a);
    char *ausing = malloc_r(size + len_a);
    memcpy(ausing, a, len_a);
    
    long numberQuotient = 0;
    ausing[len_a + numberQuotient] = '0';
    ausing[len_a+1+numberQuotient] = '\0';
    
    char *tmp = malloc_r(size * 2);
    while (1) {
        int quotient = stringDigitQuotient(ausing, b, tmp);
        fflush(stdout);
        
        if(numberQuotient == size - 1) {
            result[numberQuotient] = '\0';
            if(quotient < 5) {
                
            }
            else {
                stringDigitReuseAddInteger(result, "1");
            }
            break;
        }
        
        result[numberQuotient] = quotient + '0';
        
        numberQuotient ++;
        
        if(quotient == 0) {
            
        }
        else {
            int idx;
            for(idx=0; idx<quotient; idx++) {
                stringDigitReuseSubInteger(ausing, b);
            }
            
            if(strcmp(ausing, "0") == 0) {
                result[numberQuotient] = '\0';
                break;
            }
        }
        
        stringDigitReuseMuiltiply10n(ausing, size + len_a, 1);
    }
    
    
    
    
    
    
    
    
}


#define PPNN \
BOOL PP = (!n1->minus && !n2->minus);\
BOOL PN = (!n1->minus &&  n2->minus);\
BOOL NP = (n1->minus  && !n2->minus);\
BOOL NN = (n1->minus  &&  n2->minus);


#define DEFINE_PP BOOL PP = (!n1->minus && !n2->minus);
#define DEFINE_PN BOOL PN = (!n1->minus &&  n2->minus);
#define DEFINE_NP BOOL NP = (n1->minus  && !n2->minus);
#define DEFINE_NN BOOL NN = (n1->minus  &&  n2->minus);

int stringNumberOperateAdd(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    int ret = 0;
    PPNN
    
    if(PP || NN) {
        ret = stringNumberNoneMinusAdd(n1, n2, n);
        if(NN) {
            n->minus = YES;
        }
    }
    else if(PN) {
        ret = stringNumberNoneMinusSub(n1, n2, n);
    }
    else if(NP) {
        ret = stringNumberNoneMinusSub(n2, n1, n);
    }
    
    return ret;
}


int stringNumberOperateSub(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    int ret = 0;
    PPNN
    
    if(PP) {
        ret = stringNumberNoneMinusSub(n1, n2, n);
    }
    else if(PN) {
        ret = stringNumberNoneMinusAdd(n1, n2, n);
    }
    else if(NP) {
        ret = stringNumberNoneMinusAdd(n1, n2, n);
        n->minus = YES;
    }
    else if(NN) {
        ret = stringNumberNoneMinusSub(n2, n1, n);
    }
    
    return ret;
}


int stringNumberOperateMultiply(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    int ret = 0;
    DEFINE_PN
    DEFINE_NP
    
    ret = stringNumberNoneMinusMultiply(n1, n2, n);
    n->minus = (PN || NP);
    
    return ret;
}


int stringNumberOperateDivid(const StringNumber *n1, const StringNumber *n2, StringNumber *n)
{
    int ret = 0;
    DEFINE_PN
    DEFINE_NP
    
    ret = stringNumberNoneMinusDivid(n1, n2, n);
    n->minus = (PN || NP);
    
    return ret;
}











int stringNumberOperate(const StringNumber *n1, char op, const StringNumber *n2, StringNumber *n)
{
    int ret = 0;
    PRINTF("before %s %c %s\n", stringNumberDebugDescription(n1), op, stringNumberDebugDescription(n2));
    char tmp[1000];
    snprintf(tmp, 1000, "before %s %c %s\n", stringNumberDebugDescription(n1), op, stringNumberDebugDescription(n2));
    kmdescripe(tmp);
    
    switch (op) {
        case '+':
            ret = stringNumberOperateAdd(n1, n2, n);
            break;
            
        case '-':
            ret = stringNumberOperateSub(n1, n2, n);
            break;
            
        case '*':
            ret = stringNumberOperateMultiply(n1, n2, n);
            break;
            
        case '/':
            ret = stringNumberOperateDivid(n1, n2, n);
            break;
            
        default:
            break;
    }
    
    
    snprintf(tmp, 1000, "after %s %c %s = %s\n", stringNumberDebugDescription(n1), op, stringNumberDebugDescription(n2), stringNumberDebugDescription(n));
    kmdescripe(tmp);
    
    return ret;
}




int stringNumberReuseOperateAdd(StringNumber *n1, StringNumber *n2)
{
    int ret = 0;
    PPNN
    
    if(PP || NN) {
        ret = stringNumberNoneMinusReuseAdd(n1, n2);
        if(NN) {
            n1->minus = YES;
        }
    }
    else if(PN) {
        ret = stringNumberNoneMinusReuseSub(n1, n2);
    }
    else if(NP) {
        _stringNumberReuseSwap(n1, n2);
        ret = stringNumberNoneMinusReuseSub(n1, n2);
    }
    
    return ret;
}


int stringNumberReuseOperateSub(StringNumber *n1, StringNumber *n2)
{
    int ret = 0;
    PPNN
    
    if(PP) {
        ret = stringNumberNoneMinusReuseSub(n1, n2);
    }
    else if(PN) {
        ret = stringNumberNoneMinusReuseAdd(n1, n2);
        n1->minus = NO;
    }
    else if(NP) {
        ret = stringNumberNoneMinusReuseAdd(n1, n2);
        n1->minus = YES;
    }
    else if(NN) {
        _stringNumberReuseSwap(n1, n2);
        ret = stringNumberNoneMinusReuseSub(n1, n2);
    }
    
    return ret;
}


int stringNumberReuseOperateMultiply(StringNumber *n1, StringNumber *n2)
{
    int ret = 0;
    DEFINE_PN
    DEFINE_NP
    
    ret = stringNumberNoneMinusReuseMultiply(n1, n2);
    n1->minus = (PN || NP);
    
    return ret;
}


int stringNumberReuseOperateDivid(StringNumber *n1, StringNumber *n2)
{
    int ret = 0;
    DEFINE_PN
    DEFINE_NP
    
    ret = stringNumberNoneMinusReuseDivid(n1, n2);
    n1->minus = (PN || NP);
    
    return ret;
}





int stringNumberReuseOperate(StringNumber *n1, StringNumber *n2, char op)
{
    int ret = 0;
    
    PRINTF("stringNumberReuseOperate : [%s] %c [%s]\n", stringNumberDebugDescription(n1), op, stringNumberDebugDescription(n2));
    
    switch (op) {
        case '+':
            ret = stringNumberReuseOperateAdd(n1, n2);
            break;
            
        case '-':
            ret = stringNumberReuseOperateSub(n1, n2);
            break;
            
        case '*':
            ret = stringNumberReuseOperateMultiply(n1, n2);
            break;
            
        case '/':
            ret = stringNumberReuseOperateDivid(n1, n2);
            break;
            
        default:
            break;
    }

    return ret;
}


long stringDigitLengthFromCharacters(const char *s)
{
    if(s == NULL) {
        return 0;
    }
    
    char ch;
    long count = 0;
    while ((ch = *s)>='0' && ch <= '9') {
        count ++;
        s ++;
    }
    
    return count;
}


int stringNumberRead(StringNumber *n, const char *s)
{
    int retn = 0;
    
    n->type = StringNumberTypeInteger;
    n->minus = NO;
    n->integer = NULL;
    n->extend.vfloat.decimal = NULL;
    
    long len = 0;
    BOOL minus = NO;
    const char *r = s;
    if(r[0] == '-') {
        retn ++;
        
        minus = YES;
        len ++;
        n->minus = YES;
        r ++;
    }
    
    long integerCount = stringDigitLengthFromCharacters(r);
    long decimalCount = 0;
    if(integerCount > 0) {
        retn += integerCount;
        n->integer = strndup_r(r, integerCount);
        r += integerCount;
        stringDigitClearIntegerLeft0(&n->integer, &integerCount);
    }
    
    if(r[0] == '.' && r++ && (decimalCount = stringDigitLengthFromCharacters(r)) > 0) {
        if(n->integer == NULL) {
            n->integer = strdup_r("0");
        }
        
        retn += (1+decimalCount);
        
        n->extend.vfloat.decimal = strndup_r(r, decimalCount);
        r += decimalCount;
        
        stringDigitClearDecimalRight(&n->extend.vfloat.decimal, &decimalCount);
    }
    
    if(n->extend.vfloat.decimal == NULL
       && n->integer
       && 0 == strcmp(n->integer, "0")
       && n->minus) {
        n->minus = 0;
    }
    
    if(n->integer == NULL && n->extend.vfloat.decimal == NULL) {
        PRINTF("stringNumberRead error(%s).\n", s);
        retn = 0;
    }
    
    return retn;
}









































void stringNumberCalcDebug(StringNumber *parsedNumber, char *parsedOp, long count)
{
    long idx;
    PRINTF("----------------------------\n");
    for(idx = 0; idx <count; idx++) {
        //        PRINTF("[%ld]%c%s\n",idx, parsedOp[idx], d);
        PRINTF("%c %s ", parsedOp[idx], stringNumberDebugDescription(parsedNumber+idx));
        
        _stringNumberDebug(parsedNumber+idx);
    }
    PRINTF("\n----------------------------\n\n");
}



typedef struct {
    StringNumber *numberArray;
    char *opArray;
    long count;
    long total;
}StringNumberAndOpList;


void stringNumberArrayDebug(StringNumberAndOpList *a, const char *s)
{
    long idx;
    PRINTF("----------------------------\n%s [%ld]\n", s, a->count);
    for(idx = 0; idx <a->count; idx++) {
        PRINTF("[%ld] %c %s\n", idx, a->opArray[idx], stringNumberDebugDescription(a->numberArray+idx));
    }
    PRINTF("\n----------------------------\n\n");
}



void stringNumberArrayPush(StringNumberAndOpList *a, char op, StringNumber *n)
{
    if(n) {
        PRINTF("stringNumberArrayPush [%ld] : op [%c] ,number[%s]\n", a->count, op, stringNumberDebugDescription(n));
    }
    else {
        PRINTF("stringNumberArrayPush [%ld] : op [%c] ,number[NULL]\n", a->count, op);
    }
    
    if(a->count < a->total) {
        a->opArray[a->count] = op;
        if(n) {
            a->numberArray[a->count] = *n;
            a->numberArray[a->count].idx = 1000 + a->count;
        }
        else {
            a->numberArray[a->count].type = StringNumberTypeNull;
        }
        
        a->count ++;
    }
    else {
        //扩栈.
        assert(0);
    }
}


BOOL stringNumberArrayPushOp(StringNumberAndOpList *a, char op)
{
    BOOL valid = YES;
    //    if(a->count == 0) {
    //        if(op == '(') {
    //            valid = YES;
    //        }
    //        else {
    //            valid = NO;
    //        }
    //    }
    //    else {
    //        char opPrevious = a->opArray[a->count-1];
    //        if(op == '(') {
    //            if(opPrevious == ')') {
    //                valid = NO;
    //            }
    //        }
    //        else if(op == ')') {
    //            if(opPrevious != ')') {
    //                valid = NO;
    //            }
    //        }
    //        else {
    //            if(opPrevious == '(') {
    //                valid = NO;
    //            }
    //        }
    //    }
    
    if(valid) {
        a->opArray[a->count] = op;
        a->numberArray[a->count].type = StringNumberTypeNull;
        a->count ++;
    }
    
    return valid;
}


void stringNumberArrayPushNumber(StringNumberAndOpList *a, StringNumber *n)
{
    if(a->count == 0) {
        a->numberArray[0] = *n;
        a->opArray[0] = ' ';
        
        a->count ++;
    }
    else {
        assert(a->numberArray[a->count-1].type == StringNumberTypeNull);
        a->numberArray[a->count-1] = *n;
    }
}


char stringNumberArrayLastOp(StringNumberAndOpList *a)
{
    assert(a->count > 0);
    return a->opArray[a->count-1];
}


StringNumber * stringNumberArrayLastNumber(StringNumberAndOpList *a)
{
    assert(a->count > 0);
    return &a->numberArray[a->count-1];
}








/* >0 找到. ==0. 未找到. <0匹配错误. */
int stringNumberArrayReadParentheses(StringNumberAndOpList *a, long *left, long *right)
{
    int ret = 0;
    
    long locLeft = -1;
    long locRight = -1;
    long idx = 0;
    for(idx = 0; idx < a->count; idx ++) {
        if(a->opArray[idx] == '(') {
            locLeft = idx;
            continue;
        }
        
        if(a->opArray[idx] == ')') {
            if(locLeft >= 0) {
                locRight = idx;
//                if((locRight-locLeft) == 1) {
//                    ret = -1;
//                    break;
//                }
//                else {
                    ret = 1;
                    break;
//                }
            }
            else {
                ret = -1;
                break;
            }
        }
    }
    
    if(ret == 1) {
        *left = locLeft;
        *right = locRight;
    }
    
    return ret;
}


/* 计算. */
void stringNumberArrayInit(StringNumberAndOpList *a)
{
    a->total = 100;
    a->numberArray = malloc(sizeof(*a->numberArray) * 100);
    a->opArray = malloc(sizeof(*a->opArray)*100);
    a->count = 0;
}


void stringNumberArrayFree(StringNumberAndOpList *a)
{
    long idx;
    for (idx=0; idx<a->count; idx++) {
        stringNumberFree(a->numberArray+idx);
    }
    
    free(a->numberArray);
    free(a->opArray);
    
    a->numberArray = NULL;
    a->opArray = NULL;
    
    a->total = 0;
    a->count = 0;
}


void stringNumberArrayClear(StringNumberAndOpList *a, long loc, long length)
{
    PRINTF("stringNumberArrayClear : loc=%ld, length=%ld\n", loc, length);
    stringNumberArrayDebug(a, "before clear");
    
    long idxMove = loc;
    for(idxMove=loc;idxMove+length<a->count; idxMove++) {
        a->numberArray[idxMove] = a->numberArray[idxMove+length];
        a->opArray[idxMove] = a->opArray[idxMove+length];
    }
    a->count -= length;
    stringNumberArrayDebug(a, "after  clear");
}






void stringNumberArrayInsertAfter(StringNumberAndOpList *a, StringNumber *n, char op, long loc)
{
    if(loc > a->count - 1) {
        assert(0);
    }
    else {
        long idx;
        for(idx=a->count-1; idx>=loc+1; idx--) {
            a->numberArray[idx+1] = a->numberArray[idx];
            a->opArray[idx+1] = a->opArray[idx];
        }
        
        a->numberArray[loc+1] = *n;
        a->opArray[loc+1] = op;
        a->count++;
    }
}


/* 计算. */
int stringNumberArrayCalc(StringNumberAndOpList *a, long left, long right)
{
    int ret = 0;
    
    char srange[100];
    snprintf(srange, 100, "calc %ld to %ld", left, right);
    
    assert(left<=right);
    
    
    stringNumberArrayDebug(a, srange);
    
    StringNumber *parsedNumber = a->numberArray+left;
    char *parsedOp = a->opArray+left;
    long count = right - left + 1;
    stringNumberCalcDebug(parsedNumber, parsedOp, count);
    
    long idx;
    
    //连乘除.
    long locCounting = 0;
    long lenCounting = 0;
    PRINTF("[%d] count = %ld\n", __LINE__, a->count);
    for(idx = 1; idx <count; idx++) {
        char op = parsedOp[idx];
        PRINTF("[%ld]op = %c, number = %s\n", idx, op, stringNumberDebugDescription(parsedNumber+idx));
        
        if(op == '*' || op == '/') {
            stringNumberReuseOperate(parsedNumber+locCounting, parsedNumber+idx, op);
            lenCounting ++;
        }
        else {
            assert(op == '+' || op == '-');
            
            if(lenCounting > 0) {
                stringNumberArrayClear(a, left + locCounting + 1, lenCounting);
                idx -= lenCounting;
                count -= lenCounting;
            }
            
            locCounting = idx;
            lenCounting = 0;
        }
    }
    
    if(lenCounting > 0) {
        stringNumberArrayClear(a, left + locCounting + 1, lenCounting);
        count -= lenCounting;
    }
    
    PRINTF("calc +-\n");
    stringNumberArrayDebug(a, "111");
    
    //连加减.
    locCounting = 0;
    lenCounting = 0;
    for(idx = 1; idx <count; idx++) {
        char op = parsedOp[idx];
        PRINTF("op = %c, number = %s\n", op, stringNumberDebugDescription(parsedNumber+idx));
        if(op == '+' || op == '-') {
            stringNumberReuseOperate(parsedNumber+locCounting, parsedNumber+idx, op);
            lenCounting ++;
        }
        else {
            PRINTF("op=%c, %ld\n", op, parsedNumber[idx].idx);
            assert(0);
        }
    }
    
    if(lenCounting > 0) {
        stringNumberArrayClear(a, left + locCounting + 1, lenCounting);
    }
    
    return ret;
}


int stringNumberArrayClearParenthesesAt(StringNumberAndOpList *a, long left)
{
    int ret = 0;
    
    assert(a->opArray[left] == '('
           && (a->numberArray[left].type == StringNumberTypeInteger || a->numberArray[left].type == StringNumberTypeDivid)
           && a->opArray[left+1] == ')'
           && a->numberArray[left+1].type == StringNumberTypeNull
           );
    
    if(left == 0) {
        a->opArray[0] = ' ';
        stringNumberArrayClear(a, 1, 1);
    }
    else {
        assert(a->numberArray[left-1].type == StringNumberTypeNull);
        a->numberArray[left-1] = a->numberArray[left];
        
        stringNumberArrayClear(a, left, 2);
    }
    
    return ret;
}







void stringNumberCalcStepClearBlank(char *s)
{
    long countBlank = 0;
    
    char *t = s;
    long len = 0;
    while (*t != '\0') {
        if(*t == ' ' || *t == '\t') {
            countBlank ++;
        }
        else {
            if(countBlank > 0) {
                assert(len-countBlank >=0);
                s[len-countBlank] = s[len];
            }
        }
        
        len ++;
        t ++;
    }
    
    if(countBlank > 0) {
        len -= countBlank;
        s[len] = '\0';
    }
}


StringRange stringNumberCalcStepParenthesesRange(char *s)
{
    StringRange range;
    range.loc = -1;
    range.length = 0;
    
    long loc = 0;
    
    while (*s != '\0') {
        if(*s == '(') {
            range.loc = loc;
        }
        else if(*s == ')' && range.loc >= 0) {
            range.length = loc - range.loc + 1;
            break;
        }
        
        s ++;
        loc ++;
    }
    
    return range;
}


char *stringNumberCalcStepParenthesesRangeString(const char *s, StringRange range)
{
    long len = strlen(s);
    assert(range.loc >= 0 && range.loc<len && range.loc + range.length <= len);
    return strndup_r(s+range.loc+1, range.length-2);
}


/* None blank. */
int stringNumberArrayReadFromString(StringNumberAndOpList *a, const char *s)
{
    int ret = 0;
    
    /* 区别－为减或者操作符. */
    a->count = 0;
    
    const char *sCounting = s;
    if(sCounting[0] == '(') {
        stringNumberArrayPushOp(a, '(');
        sCounting ++;
    }
    else {
        stringNumberArrayPushOp(a, ' ');
    }
    
    int parsedOK = 1;
    
    while (1 == parsedOK) {
        if(sCounting[0] == '\0') {
            PRINTF("Read finish.\n");
            break;
        }
        
        if(stringNumberArrayLastNumber(a)->type == StringNumberTypeNull) {
            if(')' == stringNumberArrayLastOp(a)) {
                if((*sCounting == ')') || _stringCharIsOp(*sCounting)) {
                    stringNumberArrayPushOp(a, *sCounting);
                    sCounting ++;
                }
                else {
                    PRINTF("Read error ( ')' next should be ')' or op <%s>).\n", sCounting);
                    parsedOK = 0;
                    break;
                }
                
            }
            else {
                if(*sCounting == '(') {
                    stringNumberArrayPushOp(a, *sCounting);
                    sCounting ++;
                }
                else {
                    StringNumber n;
                    int retn = stringNumberRead(&n, sCounting);
                    if(retn > 0) {
                        stringNumberArrayPushNumber(a, &n);
                        sCounting += retn;
                    }
                    else {
                        PRINTF("Read error ( read number error <%s>).\n", sCounting);
                        parsedOK = 0;
                        break;
                    }
                }
            }
        }
        else {//数据已经读取到.
            if((*sCounting == ')') || _stringCharIsOp(*sCounting)) {
                stringNumberArrayPushOp(a, *sCounting);
                sCounting ++;
            }
            else {
                PRINTF("Read error ( after number error <%s>).\n", sCounting);
                parsedOK = 0;
                break;
            }
        }
    }
    
    ret = parsedOK?0:-1;
    return ret;
}





/* NoneParentheses, None blank. */
int stringNumberArrayReadFromSimplyString(StringNumberAndOpList *a, const char *s)
{
    int ret = 0;
    
    /* 区别－为减或者操作符. */
    char op;
    
    a->count = 0;
    
    const char *sCounting = s;
    while (1) {
        if(sCounting[0] == '\0') {
            PRINTF("Read finish.\n");
            break;
        }
        
        if(a->count == 0) {
            op = ' ';
        }
        else {
            if(_stringCharIsOp(sCounting[0])) {
                op = sCounting[0];
                sCounting ++;
            }
            else {
                PRINTF("Error on read op.(%s)\n", sCounting);
                ret = -1;
                break;
            }
        }
        
        StringNumber nread;
        long readLength = stringNumberRead(&nread, sCounting);
        if(readLength > 0) {
            sCounting += readLength;
            stringNumberArrayPush(a, op, &nread);
        }
        else {
            PRINTF("Error on read op.(%s)\n", sCounting);
            ret = -1;
            break;
        }
    }
    
    return ret;
}






/* 0,正确. -1.divid 0. 2.parse error. */
int stringNumberCalcNoneParentheses(const char *s, StringNumber *n)
{
    int ret = 0;
    
    StringNumberAndOpList a;
    a.total = 100;
    a.numberArray = malloc_r(sizeof(*a.numberArray) * 100);
    a.opArray = malloc_r(sizeof(*a.opArray)*100);
    a.count = 0;
    
    ret = stringNumberArrayReadFromSimplyString(&a, s);
    if(ret < 0) {
        PRINTF("parse error.(%s)\n", s);
    }
    else if(a.count == 0) {
        PRINTF("no op and number parsed.(%s)\n", s);
        ret = -1;
    }
    else if(a.count == 1) {
        PRINTF("1 op and number pared.(%s)\n", s);
        ret = 0;
        *n = a.numberArray[0];
        a.count = 0;
    }
    else {
        /* 开始计算. */
        int retCalc = stringNumberArrayCalc(&a, 0, a.count-1);
        if(0 == retCalc) {
            ret = 0;
            *n = a.numberArray[0];
            a.count = 0;
        }
        else {
            PRINTF("stringNumberArrayCalc error.\n");
            ret = -1;
        }
    }
    
    stringNumberArrayFree(&a);
    return ret;
}




char *stringNumberCalc0(const char *s)
{
    char *r = nil;
    
    char *ss = strdup_r(s);
    //清除空格.
    stringNumberCalcStepClearBlank(ss);
    
    BOOL error = NO;
    BOOL finishCalc = NO;
    
    while (1) {
        PRINTF("---: now calc [%s]\n", ss);
        
        //检查错误.
        
        /* range包含() */
        StringRange range = stringNumberCalcStepParenthesesRange(ss);
        if(range.length == 2) {
            PRINTF("---: ()\n");
            error = YES;
            break;
        }
        
        char *scalc;
        if(range.length > 2) {
            PRINTF("---: get ParenthesesRange %ld,%ld\n", range.loc, range.length);
            scalc = stringNumberCalcStepParenthesesRangeString(ss, range);
        }
        else {
            PRINTF("---: no parenthese.\n");
            finishCalc = YES;
            scalc = strdup_r(ss);
        }
        
        PRINTF("---: would calc [%s]\n", scalc);
        
        
        
        
        
        
        
        StringNumber n;
        int retCalcNoneParentheses = stringNumberCalcNoneParentheses(scalc, &n);
        free_r(scalc);
        if(retCalcNoneParentheses != 0) {
            PRINTF("---: stringNumberCalcNoneParentheses return %d.\n", retCalcNoneParentheses);
            error = YES;
            break;
        }
        
        
        
        
        
        if(finishCalc) {
            r = stringNumberDescription(&n);
            stringNumberFree(&n);
            PRINTF("--- : finish calc. result [%s]\n", r);
            break;
        }
        else {
            //替换(计算式)为结果.去掉().
            //检查是否合法.
            BOOL checkOpError = NO;
            if (range.loc != 0) {
                char opPrev = ss[range.loc-1];
                if(opPrev == '(' || _stringCharIsOp(opPrev)) {
                    
                }
                else {
                    PRINTF(": --- op before ( is [%c], invalid.\n", opPrev);
                    checkOpError = YES;
                }
            }
            
            if(range.loc+range.length<strlen(ss)) {
                char opNext = ss[range.loc+range.length];
                if(opNext == ')' || _stringCharIsOp(opNext)) {
                    
                }
                else {
                    PRINTF(": --- op after  ) is [%c], invalid.\n", opNext);
                    checkOpError = YES;
                }
            }
            
            if(checkOpError) {
                stringNumberFree(&n);
                error = YES;
                break;
            }
            
            
            
            
            if(n.type == StringNumberTypeInteger) {
                char *d = stringNumberDescription(&n);
                stringNumberFree(&n);
                char *ssTmp = _stringReplaceRange(ss, range, d);
                free_r(d);
                free_r(ss);
                ss = ssTmp;
                PRINTF("---: after replace.[%s].", ss);
            }
            else if(n.type == StringNumberTypeDivid) {
                char *ay = stringDigitMultiply(n.integer, n.extend.vdivid.y);
                char *ay_x = stringDigitAddInteger(ay, n.extend.vdivid.x);
                
                long size =1 + strlen(ay_x)+ 1 + strlen(n.extend.vdivid.y)+1;
                char *sReplace = malloc_r(size);
                if(range.loc != 0 && ss[range.loc-1] == '/') {
                    snprintf(sReplace, size, "%c%s%s/%s", '*', n.minus?"-":"", n.extend.vdivid.y, ay_x);
                    range.loc --;
                    range.length ++;
                }
                else {
                    snprintf(sReplace, size, "%s%s/%s", n.minus?"-":"", ay_x, n.extend.vdivid.y);
                }
                
                char *ssTmp = _stringReplaceRange(ss, range, sReplace);
                free_r(ay);
                free_r(ay_x);
                free_r(sReplace);
                free_r(ss);
                stringNumberFree(&n);
                ss = ssTmp;
            }
            else {
                assert(0);
            }
        }
    }
    
    if(error) {
        PRINTF("--- : calc error.\n");
        r = strdup_r("invalid");
    }
    
    free_r(ss);
    
    return r;
}


char *stringNumberCalc(const char *s)
{
    char *r = nil;
    int ret = 0;
    
    char *ss = strdup(s);
    //清除空格.
    stringNumberCalcStepClearBlank(ss);
    
    StringNumber nResult;
    
    StringNumberAndOpList a;
    stringNumberArrayInit(&a);
    
    int retRead = stringNumberArrayReadFromString(&a, ss);
    assert(retRead == 0);
    
    while (1) {
        
        if(a.count == 1) {
            nResult = a.numberArray[0];
            a.count = 0;
            break;
        }
        
        //读取()匹配.
        long left;
        long right;
        int nReadParentheses = stringNumberArrayReadParentheses(&a, &left, &right);
        if(nReadParentheses > 0) {
            stringNumberArrayCalc(&a, left, right-1);
            stringNumberArrayClearParenthesesAt(&a, left);
        }
        else if(nReadParentheses == 0) {
            stringNumberArrayCalc(&a, 0, a.count-1);
        }
        else {
            stringNumberArrayDebug(&a, NULL);
            
            assert(0);
        }
        
    }

    if(ret == 0) {
        r = stringNumberDescription(&nResult);
        stringNumberFree(&nResult);
        PRINTF("--- : finish calc. result [%s]\n", r);
    }
    else {
        PRINTF("--- : calc error.\n");
        r = strdup_r("invalid");
    }
    
    stringNumberArrayFree(&a);
    
    free(ss);
    
    
    return r;
}





u_int32_t stringNumberTestGenerateRandomInteger()
{
    return arc4random();
}









void stringNumberTestPrimeNumber()
{
    long listNumber = 0;
    char **list = malloc_r(1000*1000*sizeof(char*));
    
    list[0] = strdup_r("2");
    listNumber ++;
    
    char *number = strdup_r("3");
    char *tmp ;
    while (1) {
        long idx;
        BOOL check = NO;
        for(idx=0; idx < listNumber; idx++) {
            char *x = strdup_r(number);
            char *integer = stringDigitReuseDividGetInteger(x, list[idx]);
            free_r(integer);
            
            if(strcmp(x, "0") == 0) {
                check = NO;
            }
            else {
                check = YES;
                break;
            }
        }
        
        if(check) {
            
        }
        else {
            PRINTF("1 : %s\n", number);
            list[listNumber++] = strdup_r(number);
        }
        
        tmp = stringDigitAddInteger(number, "2");
        free_r(number);
        number = tmp;
    }
}







extern const char *kStringsReadNumber[];
extern const char *ktestArray[];
extern const char *ktestCalcAdd[];

const char *calcStrings[] = {
    
    nil
};



void stringNumberTestRead()
{
    PRINTF("---begin  test <%s>\n", __FUNCTION__);
    while(1){
        for (long idx = 0; kStringsReadNumber[idx] != nil; idx ++) {
            StringNumber n;
            BOOL valid = stringNumberRead(&n , kStringsReadNumber[idx]);
            if(valid) {
                PRINTF("%s -> [%s]\n", kStringsReadNumber[idx], stringNumberDebugDescription(&n));
                stringNumberFree(&n);
            }
            else {
                PRINTF("%s -> [%s]\n", kStringsReadNumber[idx], "invalid");
            }
            
        }
        
        break;
    }
    PRINTF("---finish test <%s>\n", __FUNCTION__);
}


void stringNumberTestFactorial()
{
    PRINTF("---begin  test <%s>\n", __FUNCTION__);
    long idx = 0;
    char *sum = strdup_r("1");
    char *scalc = malloc_r(1000000);
    for(idx=1; idx<10; idx++) {
        int n = snprintf(scalc, 1000000, "%s*%ld", sum, idx);
        assert(n < 1000000);
        
        free_r(sum);
        sum = stringNumberCalc(scalc);
        //printf("<<<>>> %ld! = %s\n", idx, sum);
    }
    
    printf("sum = [%zd] %s\n", strlen(sum), sum);
    free_r(sum);
    free_r(scalc);
    
    //        return ;
    kmcheck();
    PRINTF("---finish test <%s>\n", __FUNCTION__);
}


void stringNumberTestRandomOp()
{
    int count = 0;
    const int kSize = 100;
    NSDate *date0;
    BOOL error = 0;
    long timevalTimes = 1000000; /* 一次记时次数. */
    long times;
    
    PRINTF("------Add----------------------------\n");
    {
        
        StringNumber n1;
        n1.type = StringNumberTypeInteger;
        n1.minus = 0;
        n1.integer = malloc_r(kSize);
        snprintf(n1.integer, kSize, "%u", 123);
        n1.extend.vfloat.decimal = malloc_r(kSize);
        snprintf(n1.extend.vfloat.decimal, kSize, "%u", 46);
        
        StringNumber n2;
        n2.type = StringNumberTypeInteger;
        n2.minus = 0;
        n2.integer = malloc_r(kSize);
        snprintf(n2.integer, kSize, "%u", 1906);
        n2.extend.vfloat.decimal = malloc_r(kSize);
        snprintf(n2.extend.vfloat.decimal, kSize, "%u", 54);
        
        StringNumber n ;
        stringNumberOperate(&n1, '+', &n2, &n);
        
        PRINTF("%s + %s = %s\n", stringNumberDebugDescription(&n1), stringNumberDebugDescription(&n2), stringNumberDebugDescription(&n));
    }
    
    
    
    times = 1;
    count = 0;
    date0 = [NSDate date];
    while (count < timevalTimes * times) {//break;
        u_int32_t a = stringNumberTestGenerateRandomInteger();
        u_int32_t b = stringNumberTestGenerateRandomInteger();
        //a = 111119;
        //b = 97;
        //        u_int32_t a = 999999;
        //        u_int32_t b = 97;
        
        long long int ab = (long long int)a + (long long int)b;
        char *abs = malloc_r(kSize);
        snprintf(abs, kSize, "%lld", ab);
        
        error = 0;
        
        StringNumber n1;
        n1.type = StringNumberTypeInteger;
        n1.minus = 0;
        n1.integer = malloc_r(kSize);
        snprintf(n1.integer, kSize, "%u", a);
        n1.extend.vfloat.decimal = NULL;
        
        StringNumber n2;
        n2.type = StringNumberTypeInteger;
        n2.integer = malloc_r(kSize);
        snprintf(n2.integer, kSize, "%u", b);
        n2.extend.vfloat.decimal = NULL;
        
        StringNumber n ;
        stringNumberOperate(&n1, '+', &n2, &n);
        char *ns = stringNumberDescription(&n);
        
        if(n.type == StringNumberTypeInteger
           && 0 == strcmp(ns, abs)) {
            
        }
        else {
            PRINTF("[%d]%u + %u = %lld. error :%s\n", count, a, b, ab, ns);
            error = 1;
        }
        
        free_r(n1.integer);
        free_r(n2.integer);
        free_r(n.integer);
        free_r(abs);
        free_r(ns);
        
        count ++;
        
        if(count % timevalTimes == 0) {
            NSDate *date1 = [NSDate date];
            NSTimeInterval t = [date1 timeIntervalSinceDate:date0];
            date0 = date1;
            
            PRINTF("%zd : %lf\n", count, t);
            t = 0;
            fflush(stdout);
        }
        
        if(error) {
            break;
        }
    }
    PRINTF("------Add----------------------------\n");
    
    PRINTF("------Sub----------------------------\n");
    times = 1;
    count = 0;
    date0 = [NSDate date];
    while (count < timevalTimes * times) {//break;
        u_int32_t a = stringNumberTestGenerateRandomInteger();
        u_int32_t b = stringNumberTestGenerateRandomInteger();
        //a = 111119;
        //b = 97;
        //        u_int32_t a = 999999;
        //        u_int32_t b = 97;
        
        long long int ab = (long long int)a - (long long int)b;
        char *abs = malloc_r(kSize);
        snprintf(abs, kSize, "%lld", ab);
        
        error = 0;
        
        StringNumber n1;
        n1.type = StringNumberTypeInteger;
        n1.minus = 0;
        n1.integer = malloc_r(kSize);
        snprintf(n1.integer, kSize, "%u", a);
        n1.extend.vfloat.decimal = nil;
        
        StringNumber n2;
        n2.type = StringNumberTypeInteger;
        n2.minus = 0;
        n2.integer = malloc_r(kSize);
        snprintf(n2.integer, kSize, "%u", b);
        n2.extend.vfloat.decimal = nil;
        
        StringNumber n ;
        stringNumberOperate(&n1, '-', &n2, &n);
        char *ns = stringNumberDescription(&n);
        
        if(n.type == StringNumberTypeInteger
           && 0 == strcmp(ns, abs)) {
            
        }
        else {
            PRINTF("%u - %u = %lld. error :%s\n", a, b, ab, ns);
            error = 1;
        }
        
        free_r(n1.integer);
        free_r(n2.integer);
        free_r(n.integer);
        free_r(abs);
        free_r(ns);
        
        count ++;
        
        if(count % timevalTimes == 0) {
            NSDate *date1 = [NSDate date];
            NSTimeInterval t = [date1 timeIntervalSinceDate:date0];
            date0 = date1;
            
            PRINTF("%zd : %lf\n", count, t);
            t = 0;
            fflush(stdout);
        }
        
        if(error) {
            break;
        }
    }
    PRINTF("------Sub----------------------------\n");
    
    
    PRINTF("------Add and Sub--------------------\n");
    static long long int k10s[] = {
        1,
        10,
        100,
        1000,
        10000,
        100000,
        1000000,
        10000000,
        100000000,
        1000000000,
        10000000000,
        100000000000,
        1000000000000,
        10000000000000,
        100000000000000,
        1000000000000000,
        10000000000000000
    };
    
    
    
    
    times = 1;
    count = 0;
    date0 = [NSDate date];
    while (count < timevalTimes * times) {//break;
        /* simulate random double. */
        u_int32_t a = stringNumberTestGenerateRandomInteger();
        u_int32_t devide10a = stringNumberTestGenerateRandomInteger() % 12;
        double v1 = (double)a/(double)k10s[devide10a];
        u_int32_t minusa = stringNumberTestGenerateRandomInteger() % 2;
        if(minusa) {
            v1 = 0 - v1;
        }
        
        u_int32_t b = stringNumberTestGenerateRandomInteger();
        u_int32_t devide10b = stringNumberTestGenerateRandomInteger() % 12;
        double v2 = (double)b/(double)k10s[devide10b];
        u_int32_t minusb = stringNumberTestGenerateRandomInteger() % 2;
        if(minusb) {
            v2 = 0 - v2;
        }
        
        u_int32_t opv = stringNumberTestGenerateRandomInteger() % 2;
        char op = opv?'+':'-';
        
        char s[100];
        char *string = s;
        snprintf(s, 100, "%lf%c%lf", v1, op, v2);
        
        char r[100];
        if(opv) {
            snprintf(r, 100, "%lf", v1+v2);
        }
        else {
            snprintf(r, 100, "%lf", v1-v2);
        }
        
        {
            int nlengthRead = 0;
            
            StringNumber n1;
            nlengthRead = stringNumberRead(&n1, string);
            if(nlengthRead == 0) {
                PRINTF("0.stringNumberRead error(%s).\n", s);
                break;
            }
            
            string += nlengthRead;
            if(!(string[0] == '+'
                 || string[0] == '-')) {
                PRINTF("read op error(%s).\n", string);
            }
            
            char op = string[0];
            string ++;
            
            StringNumber n2;
            nlengthRead = stringNumberRead(&n2, string);
            if(nlengthRead == 0) {
                PRINTF("0.stringNumberRead error(%s).\n", string);
                break;
            }
            
            StringNumber n ;
            stringNumberOperate(&n1, op, &n2, &n);
            char *d1 = stringNumberDescription(&n1);
            char *d2 = stringNumberDescription(&n2);
            char *d = stringNumberDescription(&n);
            
            char *rs = r;
            long len = strlen(rs);
            stringDigitClearDecimalRight(&rs, &len);
            
            size_t len_r = strlen(r);
            size_t len_d = strlen(d);
            size_t len_cmp = MIN(len_r, len_d);
            
            if(0 != strncmp(r, d, len_cmp-1)) {
                PRINTF("count : %s, error : %s\n", r, d);
                PRINTF("[%d][%s] => [%s] %c [%s] = [%s]\n\n", count, s, d1, op, d2, d);
            }
            
            free_r(d1);
            free_r(d2);
            free_r(d);
            
            stringNumberFree(&n1);
            stringNumberFree(&n2);
            stringNumberFree(&n);
        }
        
        count ++;
        
        if(count % timevalTimes == 0) {
            NSDate *date1 = [NSDate date];
            NSTimeInterval t = [date1 timeIntervalSinceDate:date0];
            date0 = date1;
            
            PRINTF("%zd : %lf\n", count, t);
            t = 0;
            fflush(stdout);
        }
        
        if(error) {
            break;
        }
    }
    
    
    
    
    
    PRINTF("------Add and Sub--------------------\n");
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    PRINTF("------Multiply----------------------------\n");
    times = 1;
    count = 0;
    date0 = [NSDate date];
    while (count < timevalTimes * times) {//break;
        u_int32_t a = stringNumberTestGenerateRandomInteger();
        u_int32_t b = stringNumberTestGenerateRandomInteger();
        a /= 10;
        //a = 111119;
        //b = 97;
        //                u_int32_t a = 999999;
        //                u_int32_t b = 99999;
        
        long long int ab = (long long int)a * (long long int)b;
        char *abs = malloc_r(kSize);
        snprintf(abs, kSize, "%lld", ab);
        
        error = 0;
        
        StringNumber n1;
        n1.type = StringNumberTypeInteger;
        n1.minus = 0;
        n1.integer = malloc_r(kSize);
        snprintf(n1.integer, kSize, "%u", a);
        n1.extend.vfloat.decimal = nil;
        
        StringNumber n2;
        n2.type = StringNumberTypeInteger;
        n2.minus = 0;
        n2.integer = malloc_r(kSize);
        snprintf(n2.integer, kSize, "%u", b);
        n2.extend.vfloat.decimal = nil;
        
        StringNumber n ;
        stringNumberOperate(&n1, '*', &n2, &n);
        char *ns = stringNumberDescription(&n);
        
        if(n.type == StringNumberTypeInteger
           && 0 == strcmp(ns, abs)) {
            
        }
        else {
            PRINTF("[%d]%u * %u = %lld. error :%s\n", count, a, b, ab, ns);
            error = 1;
        }
        
        free_r(n1.integer);
        free_r(n2.integer);
        free_r(n.integer);
        free_r(abs);
        free_r(ns);
        
        count ++;
        
        if(count % timevalTimes == 0) {
            NSDate *date1 = [NSDate date];
            NSTimeInterval t = [date1 timeIntervalSinceDate:date0];
            date0 = date1;
            
            PRINTF("%zd : %lf\n", count, t);
            t = 0;
            fflush(stdout);
        }
        
        if(error) {
            break;
        }
        
    }
    PRINTF("------Multiply----------------------------\n");
    
    
    
}


void stringNumberTestQuotient()
{
    const long LEN_DECIMAL = 1000000;
    
    //#define LEN_DECIMAL 1000000
    char dividResult[LEN_DECIMAL];
    size_t sizeDividResult = LEN_DECIMAL;
    //    stringDigitDivid("1", "161", dividResult, sizeDividResult);
    //    PRINTF("%s\n", dividResult);
    
    stringDigitDividToQuotient("1", "128", dividResult, sizeDividResult);
    PRINTF("%s\n", dividResult);
}


void stringNumberTestCalc()
{
    printf("[%d] start [%s]\n", __LINE__, __FUNCTION__);
    long checkCount = 0;
    
    NSDate *d0 = [NSDate date];
    
//    const char **pps = ktestArray;
    const char **pps = ktestCalcAdd;
    while (*pps != nil) {
        @autoreleasepool {
        char *calc = strdup(*pps);
        char *tmp = strchr(calc, '=');
        assert(tmp);
        
        tmp[0] = '\0';
        char *expected = strdup(tmp+1);
        
//        printf("<%ld>------ calculate : %s \n", checkCount, calc);
        char *r = stringNumberCalc(calc);
        
        if(strcmp(expected, r) == 0) {
//            printf("[%ld]expected : %s. checked.----------------------------------------------------\n\n", checkCount, expected);
//            printf("[%ld]\n", checkCount);
        }
        else {
            printf("[%ld]expected : %s. error : %s.----------------------------------------------------\\n\n", checkCount, expected, r);
            assert(0);
        }
        
        free(calc);
        free(expected);
        free_r(r);
        
        kmcheck();
        
        checkCount ++;
        pps ++;
        
        if(*pps == NULL) {
            pps = ktestArray;
        }
            
            if(checkCount % 100000 == 0) {
                NSDate *d1 = [NSDate date];
                printf("[%ld] - %lf\n", checkCount, [d1 timeIntervalSinceDate:d0]);
                d0 = d1;
            }
        
        if(checkCount >= 20000000) {
            break;
        }
        }
    }
}


void stringNumberTestAlloc()
{
    NSDate *d0 = [NSDate date];
    d0 = d0;
    
    
    size_t total = 0;
    size_t size = 0;
    long idx = 0;
    for (idx=0; idx<10000000; idx++) {
        size = stringNumberTestGenerateRandomInteger() % 100 + 1;
        void *p = malloc(size);
        if(!p) {
            printf("alloc failed.\n");
            break;
        }
        total += size;
        //        printf("idx=%ld, size=%zd, tota=%zd\n", idx, size, total);
        memset(p , 1, size);
    }
    
    printf("idx=%ld, size=%zd, tota=%zd\n", idx, size, total);
    printf("finished : %lf\n", [[NSDate date] timeIntervalSinceDate:d0]);
}


void testAlloc()
{
    char *s = strdup("1");
    
    NSDate *d0 = [NSDate date];
    
    while (1) {
        break;
//        int a = 0;
//        sscanf(s, "%d", &a);
////        printf("---a=%d\n", a);
//        
//        if(a >= 1000000) break;
//        
//        a ++;
//        
//        size_t size = arc4random() % 10000000 + 16;
//        
//        char *t = malloc(size);
//        snprintf(t, size, "%d", a);
//        
//        free(s);
//        s = t;
    }
    
    free(s);
    
    printf("------%lf\n", [[NSDate date] timeIntervalSinceDate:d0]);
    
    
    
}


void testAlloc1()
{
    char s[100] = "1";
    
    NSDate *d0 = [NSDate date];
    
    while (1) {
        int a = 0;
        sscanf(s, "%d", &a);
        //        printf("---a=%d\n", a);
        
        if(a >= 10000000) break;
        
        a ++;
        
//        size_t size = arc4random() % 10 + 16;
//        size = 0;
        
        snprintf(s, 100, "%d", a);
    }
    
    
    printf("------%lf\n", [[NSDate date] timeIntervalSinceDate:d0]);
    
    
    
}


void testAlloc2()
{
    sleep(6);
    
    NSDate *d0;
    int t;
    size_t size = 1;
    
while (1) {
    
    d0 = [NSDate date];
    t = 1000000;
    
    while (t--) {
        char ss[100];
        strcpy(ss, "1234567890");
    }
    
    printf("------[%10zd] %lf\n", size, [[NSDate date] timeIntervalSinceDate:d0]);
    
    d0 = [NSDate date];
    t = 1000000;
    
    while (t--) {
        char *ss = malloc(100);
        strcpy(ss, "1234567890");
        free(ss);
    }
    
    printf("------[%10zd] %lf\n", size, [[NSDate date] timeIntervalSinceDate:d0]);
    
    
    
    
    d0 = [NSDate date];
    t = 1000000;
    size *= 2;
    
    while (t--) {
        char *s = malloc(size);
        s[size-1] = 0;
        
        free(s);
    }
    
    printf("------[%10zd] %lf\n", size, [[NSDate date] timeIntervalSinceDate:d0]);
    
    
    d0 = [NSDate date];
    t = 1000000;
    
    while (t--) {
        char ss[100];
        //        int sum = 0;
        for(int idx = 0; idx<30; idx++) {
            ss[idx] = idx;
        }
    }
    printf("------             %lf\n", [[NSDate date] timeIntervalSinceDate:d0]);
    
    d0 = [NSDate date];
    t = 1000000;
    
    int sum = 0;
    while (t--) {
        if(t > 0) {
            sum = 1;
        }
    }
    printf("------             %lf\n", [[NSDate date] timeIntervalSinceDate:d0]);
}
    
}




void stringNumberTest()
{
    sleep(2);
    //    stringNumberTestAlloc(); sleep(100); assert(0);
    
    
//    testAlloc2();
//    testAlloc1();sleep(100);
    
    stringNumberTestCalc(); sleep(100);
    
    
    
    
    
}



BOOL _numberTestIsPrime(long long int n, long long int *list, long *pnumber)
{
    BOOL isPrime = YES;
    
    if(n == 1 || n == 2) {
        return YES;
    }
    
    if(NULL == list) {
        long long int idx;
        for (idx = 2; idx*idx <= n; idx ++) {
            if(n % idx == 0) {
                isPrime = NO;
                break;
            }
        }
    }
    
    return isPrime;
}


void _numberTestGeneratePrime()
{
    long long int count = 0;
    long long int n = 1;
    for(n=3;n<1234567890123456789;n++) {
        BOOL isPrime = _numberTestIsPrime(n, NULL, 0);
        if(isPrime) {
            count ++;
            //            printf("[%lld] : %lld\n", count, n);
        }
        
        if(n % 1000000 == 0) {
            printf("%lld \n", n);
        }
    }
}


























































































































































































const char *kStringsReadNumber[] = {
    "123456",
    "456.123456",
    "0.123456",
    ".123456",
    "123.",
    "-123456",
    "-456.123456",
    "-0.123456",
    "-.123456",
    "-123.",
    ".0",
    "-.0",
    "-0.",
    "0.",
    ".01",
    ".-1",
    ".",
    "123.456.789",
    "-123.456.789",
    "-00.0010123",
    "-00.00",
    "00.00",
    "-00.00010",
    "001.00000200",
    "-001.00100000",
    "a.",
    "-.",
    nil,
    
    
    
};


const char *ktestCalcAdd[] = {
    "23+6=29",
    "23+-6=17",
    "-23+6=-17",
    "-23+-6=-29",
    
    "23+1000=1023",
    "23+-1000=-977",
    "-23+1000=977",
    "-23+-1000=-1023",
    
    "99999999999999999999999999999.999999+11.1234569=100000000000000000000000000011.1234559",
    "99999999999999999999999999999.999999+-11.1234569=99999999999999999999999999988.8765421",
    "-99999999999999999999999999999.999999+11.1234569=-99999999999999999999999999988.8765421",
    "-99999999999999999999999999999.999999+-11.1234569=-100000000000000000000000000011.1234559",
    
    
    
    
    
    
    
    nil
};




const char *ktestArray[] = {
    "1=1",
    "0+1=1",
    "99+1=100",
    "1+99=100",
    "1+0=1",
    "99999999999999999999999999999999+10000000=100000000000000000000000009999999",
    "124456+111=124567",
    "123+987654321111=987654321234",
    "0.25+0.75=1",
    "99.99+0.001=99.991",
    "999.999+0.001=1000",
    "1.23+5.6789=6.9089",
    "1.789+0.3=2.089",
    "1.2+3.4=4.6",
    "9+1.2=10.2",
    "999999+1.000000001=1000000.000000001",
    "123.456+10000000=10000123.456",
    "-0-1=-1",
    "-99-1=-100",
    "-1-99=-100",
    "-0-0=0",
    "-99999999999999999999999999999999-10000000=-100000000000000000000000009999999",
    "-124456-111=-124567",
    "-123-987654321111=-987654321234",
    "-0.25-0.75=-1",
    "-99.99-0.001=-99.991",
    "-999.999-0.001=-1000",
    "-1.23-5.6789=-6.9089",
    "-1.789-0.3=-2.089",
    "-1.2-3.4=-4.6",
    "-9-1.2=-10.2",
    "-999999-1.000000001=-1000000.000000001",
    "-123.456-10000000=-10000123.456",
    "123-123=0",
    "123.456-123.456=0",
    "0.000001-0.000001=0",
    "0.999999999999999999999999999999999999-0.999999999999999999999999999999999999=0",
    "0.0000000000000000-0.00000=0",
    "0.000001-0.1=-0.099999",
    "0.1-0.000001=0.099999",
    "1-0.99999999999999=0.00000000000001",
    "0.99999999999999-1=-0.00000000000001",
    "123.456-123.456789=-0.000789",
    "123.456789-123.456=0.000789",
    "123456789.123456789-23456789.23456789=99999999.888888899",
    "23456789.23456789-123456789.123456789=-99999999.888888899",
    "-123+123=0",
    "-123.456+123.456=0",
    "-0.000001+0.000001=0",
    "-0.999999999999999999999999999999999999+0.999999999999999999999999999999999999=0",
    "-0.0000000000000000+0.00000=0",
    "-0.000001+0.1=0.099999",
    "-0.1+0.000001=-0.099999",
    "-1+0.99999999999999=-0.00000000000001",
    "-0.99999999999999+1=0.00000000000001",
    "-123.456+123.456789=0.000789",
    "-123.456789+123.456=-0.000789",
    "-123456789.123456789+23456789.23456789=-99999999.888888899",
    "-23456789.23456789+123456789.123456789=99999999.888888899",
    "123456789*9876543210=1219326311126352690",
    "123456789*-9876543210=-1219326311126352690",
    "-123456789*9876543210=-1219326311126352690",
    "-123456789*-9876543210=1219326311126352690",
    "1.23456789*9876543210=12193263111.2635269",
    "1.23456789*9.876543210=12.1932631112635269",
    "1*2*3*4/0.5/2=24",
    "2345678910111213141516171819/2345678910111213141516171819678*12345678967/2345678910111213141516171819=12345678967/2345678910111213141516171819678",
    "(123456/5)/(123456/10)=2",
    "0*0=0",
    "1.21*0=0",
    "1*0.123456=0.123456",
    "123.456*123456789.0123456789=15241481344.3081481342784",
    "2+5/4=3&1/4",
    "2-5/4=3/4",
    "-2+5/4=-3/4",
    "-2-5/4=-3&1/4",
    "2+15/4=5&3/4",
    "2-15/4=-1&3/4",
    "-2+15/4=1&3/4",
    "-2-15/4=-5&3/4",
    "2+1/4=2&1/4",
    "2-1/4=1&3/4",
    "-2+1/4=-1&3/4",
    "-2-1/4=-2&1/4",
    "2+17/4=6&1/4",
    "2-17/4=-2&1/4",
    "-2+17/4=2&1/4",
    "-2-17/4=-6&1/4",
    
    "(1/2*2)+20/2*3/4/5*6*10-4*3/2/3/(1/6) + 10 - 10/1 + 0 + -19=60",
    "123*456=56088",
    
    "1/0.25+2*5/0.05-1/3-2/3-1/2/3+1*2/2/1/2/3=203",
    
    "1/3+1/6=1/2",
    "1/3-1/6=1/6",
    "-1/3+1/6=-1/6",
    "-1/3-1/6=-1/2",
    "(2-(-1))*(0.25+(3/4))+(((2)))*((21/8.4)/(1/4))=23",

    
    
    
    
    
    
    nil
};





#if 0

const long COMBINATION_SIZE 10000
typedef struct {
    long long int a[COMBINATION_SIZE];
    long n;
    BOOL minus;
}
CombinationInteger;


typedef struct {
    long long int aInteger[COMBINATION_SIZE];
    long nAInteger;
    
    long long int Dicimal[COMBINATION_SIZE];
    long nADicimal;
    
    char *dicimal;
    BOOL minus;
}
CombinationFloat;


typedef struct {
    long long int ax[COMBINATION_SIZE];
    long nax;
    
    long long int ay[COMBINATION_SIZE];
    long nay;
    
    BOOL minus;
}
CombinationDivid;


typedef enum {
    CombinationNumberTypeInvalid     = -1,
    CombinationNumberTypeInteger     = 0,
    CombinationNumberTypeFloat ,
    CombinationNumberTypeDivid ,
}CombinationNumberType;


typedef struct {
    CombinationNumberType type;
    union {
        CombinationInteger vInteger;
        CombinationFloat vFloat;
        CombinationFloat vDivid;
    }value;
}
CombinationNumber;


void combinationNumberSetByCharacters(CombinationNumber *n, const char* s);
CombinationNumber combinationNumberOperate(CombinationNumber n1, CombinationNumber n2, char op);


void combinatioNumberTest();












const NSInteger LEVEL = 1000000000;

char* combinationNumberDescription(CombinationNumber *n)
{
    char *s = "";
    long idx;
    
    if(n->type == CombinationNumberTypeInteger) {
        size_t size = COMBINATION_SIZE * 10 + 1;
        s = malloc(size);
        s[0] = '\0';
        
        for(idx=n->value.vInteger.n-1;idx>=0;idx--) {
            size_t len = strlen(s);
            if(idx == n->value.vInteger.n-1) {
                snprintf(s+len, size-len, "%lld", n->value.vInteger.a[idx]);
            }
            else {
                snprintf(s+len, size-len, "%09lld", n->value.vInteger.a[idx]);
            }
        }
    }
    
    return s;
}



CombinationNumber combinationNumberAdd(CombinationNumber n1, CombinationNumber n2)
{
    printf("n1 : %lld %lld\n", n1.value.vInteger.a[0], n1.value.vInteger.a[1]);
    printf("n2 : %lld %lld\n", n2.value.vInteger.a[0], n2.value.vInteger.a[1]);
    
    
    CombinationNumber n;
    n.type = CombinationNumberTypeInvalid;
    long idx;
    for (idx=0; idx<COMBINATION_SIZE; idx++) {
        n.value.vInteger.a[idx] = 0;
    }
    
    if(n1.type == CombinationNumberTypeInteger && n2.type == CombinationNumberTypeInteger) {
        n.type = CombinationNumberTypeInteger;
        
        long nCombine = MAX(n1.value.vInteger.n, n2.value.vInteger.n);
        for(idx=0; idx<nCombine;idx++) {
            n.value.vInteger.a[idx] += n1.value.vInteger.a[idx] + n2.value.vInteger.a[idx];
            printf("[%ld] : %lld + %lld = %lld\n",idx,n1.value.vInteger.a[idx], n2.value.vInteger.a[idx], n.value.vInteger.a[idx]);
            
            if(n.value.vInteger.a[idx] >= LEVEL) {
                n.value.vInteger.a[idx] -= LEVEL;
                n.value.vInteger.a[idx+1] ++;
                printf("[%ld] : %lld\n",idx,n.value.vInteger.a[idx]);
                printf("[%ld] : %lld\n",idx + 1,n.value.vInteger.a[idx+1]);
            }
            
        }
        
        if(n.value.vInteger.a[nCombine] > 0) {
            n.value.vInteger.n = nCombine + 1;
        }
        else {
            n.value.vInteger.n = nCombine;
        }
    }
    
    return n;
}


char *combinationDigitSubAlignRight(const char* s1, const char* s2, BOOL *minus)
{
    long len1 = (int)strlen(s1);
    long len2 = (int)strlen(s2);
    
    if(len1 < len2 || (len1 == len2 && strcmp(s1, s2) < 0)) {
        long tmp = len1;
        len1 = len2;
        len2 = tmp;
        
        const char *sTmp = s1;
        s1 = s2;
        s2 = sTmp;
        
        *minus = 1;
    }
    
    long size = len1 + 1;
    char *r = malloc(size);
    memcpy(r, s1, size);
    
    long idx = 0;
    for(idx = len1 - 1; idx >= len1 - len2; idx --) {
        r[idx] -= s2[idx-(len1-len2)] - '0';
        if(r[idx] < '0') {
            r[idx] += 10;
            r[idx-1] -= 1;
        }
    }
    
    for(idx = len1-len2-1; idx>0; idx --) {
        if(r[idx] < '0') {
            r[idx] += 10;
            r[idx-1] -= 1;
        }
    }
    
    int count0 = 0;
    for(idx = 0; idx < len1; idx ++) {
        if(r[idx] != '0') {
            break;
        }
        
        count0 ++;
    }
    
    if(count0 > 0) {
        for(idx = 0; idx < len1 - count0 + 1; idx ++) {
            r[idx] = r[idx + count0];
        }
        
        if(r[0] == '\0') {
            r[0] = '0';
            r[1] = '\0';
        }
    }
    
    return r;
}


CombinationNumber combinationNumberSub(CombinationNumber n1, CombinationNumber n2)
{
    CombinationNumber n;
    n.type = CombinationNumberTypeInvalid;
    
    if(n1.type == CombinationNumberTypeInteger && n2.type == CombinationNumberTypeInteger) {
        n.type = CombinationNumberTypeInteger;
        n.value.vInteger.minus = 0;
        //        n.value.vInteger.s = combinationDigitSubAlignRight(n1.value.vInteger.s, n2.value.vInteger.s, &n.value.vInteger.minus);
    }
    
    return n;
}


char *combinationDigitMultiply(const char* s1, const char* s2)
{
    long len1 = (int)strlen(s1);
    long len2 = (int)strlen(s2);
    
    if(len1 < len2 || (len1 == len2 && strcmp(s1, s2) < 0)) {
        long tmp = len1;
        len1 = len2;
        len2 = tmp;
        
        const char *sTmp = s1;
        s1 = s2;
        s2 = sTmp;
    }
    
    long len = len1 + len2;
    long size = len + 1;
    char *r = malloc(size);
    r[size-1] = '\0';
    memset(r, 0, len);
    
    long idx2 = 0;
    long idx1 = 0;
    for(idx2 = 0; idx2 < len2; idx2 ++)
        for(idx1 = 0; idx1 < len1; idx1 ++) {
            r[len-1-idx1-idx2] += (s2[len2-1-idx2] - '0') * (s1[len1-1-idx1] - '0');
            if(r[len-1-idx1-idx2] >= 10) {
                r[len-1-idx1-idx2-1] += r[len-1-idx1-idx2] / 10;
                r[len-1-idx1-idx2] = r[len-1-idx1-idx2] % 10;
            }
        }
    
    int count0 = 0;
    long idx;
    for(idx = 0; idx < len1; idx ++) {
        if(r[idx] != 0) {
            break;
        }
        
        count0 ++;
    }
    
    for(idx = 0; idx < len - count0; idx ++) {
        r[idx] = r[idx + count0] + '0';
    }
    r[len-count0] = '\0';
    
    return r;
}


CombinationNumber combinationNumberMultiply(CombinationNumber n1, CombinationNumber n2)
{
    CombinationNumber n;
    n.type = CombinationNumberTypeInvalid;
    
    if(n1.type == CombinationNumberTypeInteger && n2.type == CombinationNumberTypeInteger) {
        n.type = CombinationNumberTypeInteger;
        n.value.vInteger.minus = 0;
        //        n.value.vInteger.s = combinationDigitMultiply(n1.value.vInteger.s, n2.value.vInteger.s);
    }
    
    return n;
}


void combinationNumberIntegerDebug(CombinationNumber *n)
{
    long idx;
    for(idx = 0; idx < n->value.vInteger.n; idx++) {
        printf("[%lld]", n->value.vInteger.a[idx]);
    }
    printf("\n");
}




void combinationNumberIntegerCarry(CombinationNumber *n)
{
    //printf("start carry.\n");
    //combinationNumberIntegerDebug(n);
    long idx ;
    for(idx = 0; idx < n->value.vInteger.n - 1; idx++) {
        if(n->value.vInteger.a[idx] >= LEVEL) {
            //printf("from %lld to ", n->value.vInteger.a[idx+1]);
            n->value.vInteger.a[idx+1] += n->value.vInteger.a[idx] / LEVEL;
            //printf("%lld \n", n->value.vInteger.a[idx+1]);
            
            n->value.vInteger.a[idx] = n->value.vInteger.a[idx] % LEVEL;
        }
    }
    
    for (idx=n->value.vInteger.n-1; idx < COMBINATION_SIZE; idx++) {
        if(n->value.vInteger.a[idx] >= LEVEL) {
            n->value.vInteger.a[idx+1] += n->value.vInteger.a[idx] / LEVEL;
            n->value.vInteger.a[idx] = n->value.vInteger.a[idx] % LEVEL;
            n->value.vInteger.n ++;
        }
        else {
            break;
        }
    }
    //combinationNumberIntegerDebug(n);
    //printf("finish carry.\n");
}


void combinationNumberMultiplyNumber(CombinationNumber *n, long long int m)
{
    char *s = combinationNumberDescription(n);
    //printf("%s * %lld = ", s, m);
    free(s);
    
    long idx = 0;
    if(m < 1000000) {
        for(idx = 0; idx < n->value.vInteger.n; idx++) {
            n->value.vInteger.a[idx] *= m;
        }
        
        combinationNumberIntegerCarry(n);
    }
    
    s = combinationNumberDescription(n);
    //printf("%s\n", s);
    free(s);
    
}










CombinationNumber combinationNumberOperate(CombinationNumber n1, CombinationNumber n2, char op)
{
    CombinationNumber n;
    
    switch (op) {
        case '+':
            n = combinationNumberAdd(n1, n2);
            break;
            
        case '-':
            n = combinationNumberSub(n1, n2);
            break;
            
        case '*':
            n = combinationNumberMultiply(n1, n2);
            break;
            
        default:
            break;
    }
    
    
    
    
    
    
    
    
    return n;
}














u_int32_t randomInteger();


void combinationNumberTest()
{
    int count = 0;
    const int kSize = 100;
    NSDate *date0;
    BOOL error = 0;
    long timevalTimes = 1000000; /* 一次记时次数. */
    long times;
    
    printf("------Add----------------------------\n");
    times = 0;
    count = 0;
    date0 = [NSDate date];
    while (1) {//break;
        long long int a = randomInteger();
        long long int b = randomInteger();
        //a = 111119;
        //b = 97;
        //        u_int32_t a = 999999;
        //        u_int32_t b = 97;
        
        long long int ab = (long long int)a + (long long int)b;
        char *abs = malloc(kSize);
        snprintf(abs, kSize, "%lld", ab);
        
        error = 0;
        
        CombinationNumber n1;
        n1.type = CombinationNumberTypeInteger;
        if(a >= LEVEL) {
            n1.value.vInteger.n = 2;
            n1.value.vInteger.a[0] = a % LEVEL;
            n1.value.vInteger.a[1] = a / LEVEL;
        }
        else {
            n1.value.vInteger.n = 1;
            n1.value.vInteger.a[0] = a ;
            n1.value.vInteger.a[1] = 0;
        }
        
        CombinationNumber n2;
        n2.type = CombinationNumberTypeInteger;
        if(b >= LEVEL) {
            n2.value.vInteger.n = 2;
            n2.value.vInteger.a[0] = b % LEVEL;
            n2.value.vInteger.a[1] = b / LEVEL;
        }
        else {
            n2.value.vInteger.n = 1;
            n2.value.vInteger.a[0] = b ;
            n2.value.vInteger.a[1] = 0;
        }
        
        CombinationNumber n ;
        n = combinationNumberOperate(n1, n2, '+');
        char *ns = combinationNumberDescription(&n);
        
        if(n.type == CombinationNumberTypeInteger
           && 0 == strcmp(ns, abs)) {
            
        }
        else {
            printf("%lld + %lld = %lld. error :%s\n", a, b, ab, ns);
            error = 1;
        }
        
        //        free(n1.value.vInteger.s);
        //        free(n2.value.vInteger.s);
        //        free(n.value.vInteger.s);
        free(abs);
        free(ns);
        
        count ++;
        
        if(count % timevalTimes == 0) {
            NSDate *date1 = [NSDate date];
            NSTimeInterval t = [date1 timeIntervalSinceDate:date0];
            date0 = date1;
            
            printf("%zd : %lf\n", count, t);
            fflush(stdout);
        }
        
        if(error) {
            break;
        }
        
        if(count >= timevalTimes * times) {
            break;
        }
    }
    printf("------Add----------------------------\n");
    
    printf("------Sub----------------------------\n");
    times = 0;
    count = 0;
    date0 = [NSDate date];
    while (1) {//break;
        u_int32_t a = randomInteger();
        u_int32_t b = randomInteger();
        //a = 111119;
        //b = 97;
        //        u_int32_t a = 999999;
        //        u_int32_t b = 97;
        
        long long int ab = (long long int)a - (long long int)b;
        char *abs = malloc(kSize);
        snprintf(abs, kSize, "%lld", ab);
        
        error = 0;
        
        CombinationNumber n1;
        n1.type = CombinationNumberTypeInteger;
        if(a >= LEVEL) {
            n1.value.vInteger.n = 2;
            n1.value.vInteger.a[0] = a % LEVEL;
            n1.value.vInteger.a[1] = a / LEVEL;
        }
        else {
            n1.value.vInteger.n = 1;
            n1.value.vInteger.a[0] = a ;
        }
        
        
        CombinationNumber n2;
        n2.type = CombinationNumberTypeInteger;
        if(b >= LEVEL) {
            n2.value.vInteger.n = 2;
            n2.value.vInteger.a[0] = b % LEVEL;
            n2.value.vInteger.a[1] = b / LEVEL;
        }
        else {
            n2.value.vInteger.n = 1;
            n2.value.vInteger.a[0] = b ;
        }
        
        
        CombinationNumber n ;
        n = combinationNumberOperate(n1, n2, '-');
        char *ns = combinationNumberDescription(&n);
        
        if(n.type == CombinationNumberTypeInteger
           && 0 == strcmp(ns, abs)) {
            
        }
        else {
            printf("%u - %u = %lld. error :%s\n", a, b, ab, ns);
            error = 1;
        }
        
        //        free(n1.value.vInteger.s);
        //        free(n2.value.vInteger.s);
        //        free(n.value.vInteger.s);
        free(abs);
        free(ns);
        
        count ++;
        
        if(count % timevalTimes == 0) {
            NSDate *date1 = [NSDate date];
            NSTimeInterval t = [date1 timeIntervalSinceDate:date0];
            date0 = date1;
            
            printf("%zd : %lf\n", count, t);
            fflush(stdout);
        }
        
        if(error) {
            break;
        }
        
        if(count >= timevalTimes * times) {
            break;
        }
    }
    printf("------Sub----------------------------\n");
    
    printf("------Multiply----------------------------\n");
    times = 0;
    count = 0;
    date0 = [NSDate date];
    while (1) {//break;
        u_int32_t a = randomInteger();
        u_int32_t b = randomInteger();
        a /= 10;
        //a = 111119;
        //b = 97;
        //                u_int32_t a = 999999;
        //                u_int32_t b = 99999;
        
        long long int ab = (long long int)a * (long long int)b;
        char *abs = malloc(kSize);
        snprintf(abs, kSize, "%lld", ab);
        
        error = 0;
        
        CombinationNumber n1;
        n1.type = CombinationNumberTypeInteger;
        //        n1.value.vInteger.s = malloc(kSize);
        //        snprintf(n1.value.vInteger.s, kSize, "%u", a);
        
        CombinationNumber n2;
        n2.type = CombinationNumberTypeInteger;
        //        n2.value.vInteger.s = malloc(kSize);
        //        snprintf(n2.value.vInteger.s, kSize, "%u", b);
        
        CombinationNumber n ;
        n = combinationNumberOperate(n1, n2, '*');
        char *ns = combinationNumberDescription(&n);
        
        if(n.type == CombinationNumberTypeInteger
           && 0 == strcmp(ns, abs)) {
            
        }
        else {
            printf("[%d]%u * %u = %lld. error :%s\n", count, a, b, ab, ns);
            error = 1;
        }
        
        //        free(n1.value.vInteger.s);
        //        free(n2.value.vInteger.s);
        //        free(n.value.vInteger.s);
        free(abs);
        free(ns);
        
        count ++;
        
        if(count % timevalTimes == 0) {
            NSDate *date1 = [NSDate date];
            NSTimeInterval t = [date1 timeIntervalSinceDate:date0];
            date0 = date1;
            
            printf("%zd : %lf\n", count, t);
            fflush(stdout);
        }
        
        if(error) {
            break;
        }
        
        if(count >= timevalTimes * times) {
            break;
        }
    }
    printf("------Multiply----------------------------\n");
    
    //    BOOL divisible(const char *a, const char *b);
    //    BOOL b = divisible("1001", "3");
    //    printf("%s\n", b?"YES":"NO");
    
    
    //    void primeNumber();
    //    //    primeNumber();
    //
    //    BOOL isPrimeNumber(const char* s);
    //    isPrimeNumber("12345678908594385934751892483392842348298423");
    
    
    //    CombinationNumber sum;
    //    sum.type = CombinationNumberTypeInteger;
    //    long idx = 0;
    //    for(idx=0; idx<COMBINATION_SIZE; idx++) {
    //        sum.value.vInteger.a[idx] = 0;
    //    }
    //    sum.value.vInteger.a[0] = 1;
    //    sum.value.vInteger.n = 1;
    //
    //    long nn = 1;
    //    while (1) {
    //        combinationNumberMultiplyNumber(&sum, nn);
    //        char *s = combinationNumberDescription(&sum);
    //        printf("%ld! = %s\n", nn, s);
    //
    //        free(s);
    //        nn ++;
    //    }
    
    
    
    
    
    
}






BOOL cdivisible1(char *a, const char *b)
{
    
    
    BOOL r = NO;
    BOOL minus = NO;
    while (1) {
        //printf("------ %s / %s\n", a, b);
        
        
        size_t len_a = strlen(a);
        size_t len_b = strlen(b);
        
        if(len_a == 1 && a[0] == '0') {
            r = YES;
            break;
        }
        
        if(len_a < len_b) {
            r = NO;
            break;
        }
        
        int c = strcmp(a, b);
        
        if(c == 0) {
            r = YES;
            break;
        }
        
        long len0;
        
        if(c > 0) {
            if(len_a == len_b) {
                char *t = combinationDigitSubAlignRight(a, b, &minus);
                strcpy(a, t);
                free(t);
                continue;
            }
            else {
                len0 = len_a - len_b;
            }
        }
        else {
            if(len_a == len_b) {
                r = NO;
                break;
            }
            else if((len_a - len_b) == 1){
                char *t = combinationDigitSubAlignRight(a, b, &minus);
                strcpy(a, t);
                free(t);
                continue;
            }
            else {
                len0 = len_a - len_b - 1;
            }
        }
        
        char *s10 = malloc(len0 + 1 + 1);
        s10[0] = '1';
        s10[len0 + 1] = '\0';
        
        int idx = 0;
        for(idx = 1; idx < len0 + 1; idx++) {
            s10[idx] = '0';
        }
        
        //printf("s10 = %s\n", s10);
        
        char *s1 = combinationDigitMultiply(b, s10);
        //printf("would sub : %s\n", s1);
        
        char *leftA = combinationDigitSubAlignRight(a, s1, &minus);
        //printf("after sub : %s\n", leftA);
        
        strcpy(a, leftA);
        
        free(s10);
        free(s1);
        free(leftA);
        
        continue;
    }
    
    return r;
}




BOOL cdivisible(const char *a, const char *b)
{
    size_t len_a = strlen(a);
    size_t len_b = strlen(b);
    
    if(len_a == 1 && a[0] == '0') {
        return YES;
    }
    
    if(len_a < len_b) {
        return NO;
    }
    
    char *s = malloc(len_a + 1);
    memcpy(s, a, len_a+1);
    BOOL r = cdivisible1(s, b);
    free(s);
    
    return r;
}


void cprimeNumber()
{
    long listNumber = 0;
    char **list = malloc(1000*1000*sizeof(char*));
    
    list[0] = "2";
    listNumber ++;
    
    char *number = strdup("3");
    char *tmp ;
    while (1) {
        long idx;
        BOOL check = NO;
        for(idx=0; idx < listNumber; idx++) {
            check = cdivisible(number, list[idx]);
            if(check) {
                break;
            }
        }
        
        if(check) {
            //printf("0 : %s\n", number);
            
            
        }
        else {
            printf("1 : %s\n", number);
            list[listNumber++] = strdup(number);
        }
        //sleep(1);
        
        //        tmp = combinationDigitAddAlignRight(number, "2");
        free(number);
        number = tmp;
    }
    
}


BOOL cisPrimeNumber(const char* s)
{
    BOOL r = YES;
    
    char *b = strdup("3");
    char *t;
    while (1) {
        BOOL divided = cdivisible(s, b);
        if(divided) {
            printf("%s", b);
            r = NO;
            free(b);
            break;
        }
        
        //        t = combinationDigitAddAlignRight(b, "2");
        free(b);
        b = t;
        
        
    }
    
    return r;
}


void tst()
{
    long long int *a = malloc(sizeof(*a) * 1000*1000 * 1000);
    long number = 0;
    
    a[number++] = 2;
    long long int n = 3;
    
    while (1) {
        BOOL isPrime = YES;
        for(long idx = 0; idx < number; idx ++) {
            if(a[idx] * a[idx] > n ) break;
            //            if(n / a[idx] < a[idx]) break;
            
            if(n % a[idx] == 0) {
                isPrime = NO;
                break;
            }
        }
        
        if(isPrime) {
            printf("[%ld] : %lld\n", number, n);
            if(number % 1000 == 0) {
                //                printf("[%ld] : %lld %lf                  %lf\n", number, n, (double)(number+1) / (double)n, [[NSDate date] timeIntervalSinceDate:date0]);
            }
            a[number++] = n;
        }
        
        n += 2;
    }
}
#endif



































#if 0

#if USE_MEMORY_POOL

@interface MemorySeg : NSObject

@property (nonatomic, assign) long offset;
@property (nonatomic, assign) long length;
@property (nonatomic, assign) BOOL isFree;

+ (MemorySeg*)memorySegWith:(long)offset length:(long)length isFree:(BOOL)isFree;

@end


@implementation MemorySeg
+ (MemorySeg*)memorySegWith:(long)offset length:(long)length isFree:(BOOL)isFree
{
    MemorySeg *seg = [[MemorySeg alloc] init];
    seg.offset = offset;
    seg.length = length;
    seg.isFree = isFree;
    
    return seg;
}



@end

static NSMutableArray<MemorySeg*> *ksegs = nil;
static void *kmv = NULL;


void kminit()
{
    if(!kmv) {
        size_t size = 1024*1024;
        kmv = malloc(size);
        ksegs = [[NSMutableArray alloc] init];
        [ksegs addObject:[MemorySeg memorySegWith:0 length:size isFree:YES]];
    }
}

void kmdescripe(const char *es)
{
    if(!keable_kmdescripe) return;
    
    PRINTF("------%s\n", es);
    for(MemorySeg *seg in ksegs) {
        seg.offset = seg.offset;
    }
    PRINTF("\n\n");
}

void *malloc_d(size_t size, const char *function, int line)
{
    kminit();
    
    if(keable_kmdescripe) {
        PRINTF("alloc : %lld\n", pv);
    }
    
    void *p = NULL;
    
    for(NSInteger idx = 0; idx < ksegs.count; idx ++) {
        MemorySeg *seg = ksegs[idx];
        if(seg.isFree && seg.length >= size) {
            p = kmv + seg.offset;
            if(seg.length == size) {
                seg.isFree = NO;
            }
            else {
                MemorySeg *allocedSeg = [MemorySeg memorySegWith:seg.offset length:size isFree:NO];
                seg.offset += size;
                seg.length -= size;
                [ksegs insertObject:allocedSeg atIndex:idx];
            }
            
            break;
        }
    }
    
    kmdescripe("after alloc");
    
    return p;
}


void free_d(void *p, const char *function, int line)
{
    kmdescripe("\n\nbefore free");
    
    NSInteger idxFree = NSNotFound;
    for(NSInteger idx = 0; idx < ksegs.count; idx ++) {
        MemorySeg *seg = ksegs[idx];
        if((kmv+seg.offset) == p && !seg.isFree) {
            idxFree = idx;
            break;
        }
    }
    
    assert(idxFree != NSNotFound);
    
    BOOL assemblePrev = (idxFree>0 && ksegs[idxFree-1].isFree);
    BOOL assembleNext = (idxFree < (ksegs.count-1) && ksegs[idxFree+1].isFree) ;
    if(assemblePrev && assembleNext) {
        ksegs[idxFree-1].length += (ksegs[idxFree].length + ksegs[idxFree+1].length);
        [ksegs removeObjectsInRange:NSMakeRange(idxFree, 2)];
    }
    else if(assemblePrev) {
        ksegs[idxFree-1].length += (ksegs[idxFree].length);
        [ksegs removeObjectAtIndex:idxFree];
    }
    else if(assembleNext) {
        ksegs[idxFree].length += ksegs[idxFree+1].length;
        ksegs[idxFree].isFree = YES;
        [ksegs removeObjectAtIndex:idxFree+1];
    }
    else {
        ksegs[idxFree].isFree = YES;
    }
    
    kmdescripe("after free");
}


void kmcheck()
{
    
}

#endif

#endif





























































































































































































































































































































































































































































































#if 0

StringNumber _stringNumberAdd(StringNumber* n1, StringNumber* n2)
{
    assert(!n1->minus);
    assert(!n2->minus);
    
    _stringNumberDebug(n1);
    _stringNumberDebug(n2);
    
    StringNumber n;
    n.type = StringNumberTypeInvalid;
    
    if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeInteger) {
        n.type = StringNumberTypeInteger;
        n.integer = stringDigitAddInteger(n1->integer, n2->integer);
        BOOL carry = NO;
        n.extend.vfloat.decimal = stringDigitAddDecimal(n1->extend.vfloat.decimal, n2->extend.vfloat.decimal, &carry);
        if(carry) {
            char *t = stringDigitAddInteger(n.integer, "1");
            free_r(n.integer);
            n.integer = t;
        }
    }
    else if(n1->type == StringNumberTypeInteger && n2->type == StringNumberTypeDivid) {
        if(n1->extend.vfloat.decimal == NULL) {
            n.type = StringNumberTypeDivid;
            n.integer = stringDigitAddInteger(n1->integer, n2->integer);
            n.extend.vdivid.x = strdup_r(n2->extend.vdivid.x);
            n.extend.vdivid.y = strdup_r(n2->extend.vdivid.y);
        }
        else {
            StringNumber n1ToDivid;
            stringNumberIntegerToDivid(n1, &n1ToDivid);
            n = _stringNumberAdd(&n1ToDivid, n2);
            stringNumberFree(&n1ToDivid);
        }
    }
    else if(n1->type == StringNumberTypeDivid && n2->type == StringNumberTypeInteger) {
        n = _stringNumberAdd(n2, n1);
    }
    else {
        n.type = StringNumberTypeDivid;
        
        n.integer = stringDigitAddInteger(n1->integer, n2->integer);
        BOOL carry = 0;
        stringDigitDividAdd(n1->extend.vdivid.x, n1->extend.vdivid.y, n2->extend.vdivid.x, n2->extend.vdivid.y, &n.extend.vdivid.x, &n.extend.vdivid.y, &carry);
        if(carry) {
            char *tmp = stringDigitAddInteger(n.integer, "1");
            free_r(n.integer);
            n.integer = tmp;
        }
    }
    
    assert(n.type != StringNumberTypeInvalid);
    
    stringNumberSimplify(&n);
    
    return n;
}

















#endif