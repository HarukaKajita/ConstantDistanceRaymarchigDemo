
///ret : 0.0 - <1.0
float rand(float n){return frac(sin(n) * 43758.5453123);}

///ret : 0.0 - <1.0
float rand(float2 co){
    return rand(dot(co.xy ,float2(12.9898,78.233)));
}

///ret : 0.0 - <1.0
float rand(float3 vec){//zは独自
    return rand(dot(vec, float3(12.9898, 78.233, 47.3562985)));
}

//ret : (0, 0) - <(1, 1)
//2Dランダム
float3 rand3D(float3 vec){
    
    float rand1 = dot(vec,float3(127.1, 311.7, 264.7));
    float rand2 = dot(vec,float3(269.5, 183.3, 336.2));
    float rand3 = dot(vec,float3(301.7, 231.1, 142.6));
    
    float3 rand = float3(rand1, rand2, rand3);
    return -1.0 + 2.0 * frac(sin(rand) * 43758.5453123);
}


///ret : -1 - +1
float2 rand2D(float2 st){
    st = float2( dot(st,float2(127.1,311.7)),
              dot(st,float2(269.5,183.3)) );
    return -1.0 + 2.0*frac(sin(st)*43758.5453123);
}

///Value Noise
///ret : 0.0 - <1.0
float valNoise(float x){
    float i = floor(x);
    float f = frac(x);
    
    float rand_0 = rand(i);
    float rand_1 = rand(i + 1.0);
    return lerp(rand_0, rand_1, smoothstep(0.0, 1.0, f));
}

float valNoise(float2 uv){
    float2 i = floor(uv);
    float2 f = frac(uv);
    
    float2 sm = smoothstep(0.0, 1.0, f);
    
    //o = origin
    float rand_o  = rand(i);
    float rand_x  = rand(i + float2(1.0, 0.0));
    float rand_y  = rand(i + float2(0.0, 1.0));
    float rand_xy = rand(i + float2(1.0, 1.0));

    float value_x  = lerp(rand_o, rand_x , sm.x);
    float value_y1 = lerp(0, rand_y - rand_o, sm.y);
    float value_y2 = lerp(0, rand_xy - rand_x, sm.y);
    float value_y  = lerp(value_y1, value_y2, sm.x);//1と2をブレンド
    return value_x + value_y;
}

float valNoise(float3 pos){
    float3 i = floor(pos);
    float3 f = frac(pos);
    
    float3 sm = smoothstep(0, 1, f);
    
    float rand_o   = rand(i);
    float rand_x   = rand(i + float3(1.0, 0.0, 0.0));
    float rand_y   = rand(i + float3(0.0, 1.0, 0.0));
    float rand_z   = rand(i + float3(0.0, 0.0, 1.0));
    float rand_xy  = rand(i + float3(1.0, 1.0, 0.0));
    float rand_xz  = rand(i + float3(1.0, 0.0, 1.0));
    float rand_yz  = rand(i + float3(0.0, 1.0, 1.0));
    float rand_xyz = rand(i + float3(1.0, 1.0, 1.0));
    
    
    //底面
    float value_x1   = lerp(rand_o   , rand_x , sm.x);
    float value_z1   = lerp(0, rand_z - rand_o, sm.z);//2辺のZ軸ノイズ ///*
    float value_z2   = lerp(0, rand_xz - rand_x, sm.z);                 ///*
    float value_z_x1 = lerp(value_z1 , value_z2, sm.x);//xでブレンド
    float noiseXZ1   = value_x1 + value_z_x1;//XZ平面上の2Dノイズ
    
    //天井
    float value_x2   = lerp(rand_y, rand_xy, sm.x);
    float value_z3   = lerp(0, rand_yz - rand_y, sm.z);
    float value_z4   = lerp(0, rand_xyz - rand_xy, sm.z);
    float value_z_x2 = lerp(value_z3, value_z4, sm.x);
    float noiseXZ2   = value_x2 + value_z_x2;//XZ平面上の2Dノイズ
    
    float noise = lerp(noiseXZ1, noiseXZ2, sm.y);//底面の2Dノイズと天井の2DノイズをYでsmoothstep補間
    
    return noise;
}

//Perline Noise

float pNoise(float pos){
    return pNoise(float2(pos, 0));
}

float pNoise(float2 pos){
    float2 i_o = floor(pos);
    float2 f = frac(pos);
    
    float2 sm = smoothstep(0, 1, f);
    
    float2 i_x  = i_o + float2(1, 0);
    float2 i_y  = i_o + float2(0, 1);
    float2 i_xy = i_o + float2(1, 1);
    float2 rand_o  = rand2D(i_o);
    float2 rand_x  = rand2D(i_x);
    float2 rand_y  = rand2D(i_y);
    float2 rand_xy = rand2D(i_xy);
    
    float2 toPos_o  = pos - i_o;
    float2 toPos_x  = pos - i_x;
    float2 toPos_y  = pos - i_y;
    float2 toPos_xy = pos - i_xy;
    
    float dot_o  = dot(rand_o , toPos_o )*0.5+0.5;
    float dot_x  = dot(rand_x , toPos_x )*0.5+0.5;
    float dot_y  = dot(rand_y , toPos_y )*0.5+0.5;
    float dot_xy = dot(rand_xy, toPos_xy)*0.5+0.5;
    
    float value1 = lerp(dot_o, dot_x, sm.x);
    float value2 = lerp(dot_y, dot_xy, sm.x);
    float value3 = lerp(0, value2 - value1, sm.y);
    return value1 + value3;
}

float pNoise(float3 pos){
    float3 i_o = floor(pos);
    float3 f = frac(pos);
    
    float3 sm = smoothstep(0, 1, f);
    
    float3 i_x   = i_o + float3(1, 0, 0);
    float3 i_y   = i_o + float3(0, 1, 0);
    float3 i_z   = i_o + float3(0, 0, 1);
    float3 i_xy  = i_o + float3(1, 1, 0);
    float3 i_xz  = i_o + float3(1, 0, 1);
    float3 i_yz  = i_o + float3(0, 1, 1);
    float3 i_xyz = i_o + float3(1, 1, 1);
    float3 rand_o   = rand3D(i_o);
    float3 rand_x   = rand3D(i_x);
    float3 rand_y   = rand3D(i_y);
    float3 rand_z   = rand3D(i_z);
    float3 rand_xy  = rand3D(i_xy);
    float3 rand_xz  = rand3D(i_xz);
    float3 rand_yz  = rand3D(i_yz);
    float3 rand_xyz = rand3D(i_xyz);
    
    float3 toPos_o   = pos - i_o;
    float3 toPos_x   = pos - i_x;
    float3 toPos_y   = pos - i_y;
    float3 toPos_z   = pos - i_z;
    float3 toPos_xy  = pos - i_xy;
    float3 toPos_xz  = pos - i_xz;
    float3 toPos_yz  = pos - i_yz;
    float3 toPos_xyz = pos - i_xyz;
     
    float dot_o   = dot(rand_o ,  toPos_o  )*0.5+0.5;
    float dot_x   = dot(rand_x ,  toPos_x  )*0.5+0.5;
    float dot_y   = dot(rand_y ,  toPos_y  )*0.5+0.5;
    float dot_z   = dot(rand_z ,  toPos_z  )*0.5+0.5;
    float dot_xy  = dot(rand_xy,  toPos_xy )*0.5+0.5;
    float dot_xz  = dot(rand_xz,  toPos_xz )*0.5+0.5;
    float dot_yz  = dot(rand_yz,  toPos_yz )*0.5+0.5;
    float dot_xyz = dot(rand_xyz, toPos_xyz)*0.5+0.5;
    //底面
    float value_x1 = lerp(dot_o, dot_x, sm.x);
    float value_z1 = lerp(0, dot_z - dot_o, sm.z);
    float value_z2 = lerp(0, dot_xz - dot_x, sm.z);
    float value_z_x1 = lerp(value_z1, value_z2, sm.x);//xでブレンド
    float noiseXZ1 = value_x1 + value_z_x1;
    
    //天井
    float value_x2 = lerp(dot_y, dot_xy, sm.x);
    float value_z3 = lerp(0, dot_yz - dot_y, sm.z);
    float value_z4 = lerp(0, dot_xyz - dot_xy, sm.z);
    float value_z_x2 = lerp(value_z3, value_z4, sm.x);//xでブレンド
    float noiseXZ2 = value_x2 + value_z_x2;
    
    return lerp(noiseXZ1, noiseXZ2, sm.y);//yでブレンド
}

float2 pNoise2D(float2 pos){
    float2 pos_0 = pos;
    float2 pos_1 = float2(pos.y, pos.x);//対称性が生まれそうだから工夫が必要かも
    float n_0 = pNoise(pos_0);
    float n_1 = pNoise(pos_1);
    return float2(n_0, n_1);
}

float3 pNoise3D(float3 pos){
    float3 pos_0 = pos;
    float3 pos_1 = float3(pos.y, pos.z, pos.x);
    float3 pos_2 = float3(pos.z, pos.x, pos.y);
    float n_0 = pNoise(pos_0);
    float n_1 = pNoise(pos_1);
    float n_2 = pNoise(pos_2);
    return float3(n_0, n_1, n_2);
}

//Cellular Noise

float cNoise(float2 pos){
    float2 i_o = floor(pos);
    //周辺のセル
    //p : plus ,  m : minus
    float2 i_px   = i_o + float2( 1,  0);
    float2 i_mx   = i_o + float2(-1,  0);
    float2 i_py   = i_o + float2( 0,  1);
    float2 i_my   = i_o + float2( 0, -1);
    float2 i_pxpy = i_o + float2( 1,  1);
    float2 i_pxmy = i_o + float2( 1, -1);
    float2 i_mxpy = i_o + float2(-1,  1);
    float2 i_mxmy = i_o + float2(-1, -1);
    
    float2 rand_o    = i_o    + rand2D(i_o)   *0.5+0.5;
    float2 rand_px   = i_px   + rand2D(i_px)  *0.5+0.5;
    float2 rand_mx   = i_mx   + rand2D(i_mx)  *0.5+0.5;
    float2 rand_py   = i_py   + rand2D(i_py)  *0.5+0.5;
    float2 rand_my   = i_my   + rand2D(i_my)  *0.5+0.5;
    float2 rand_pxpy = i_pxpy + rand2D(i_pxpy)*0.5+0.5;
    float2 rand_pxmy = i_pxmy + rand2D(i_pxmy)*0.5+0.5;
    float2 rand_mxpy = i_mxpy + rand2D(i_mxpy)*0.5+0.5;
    float2 rand_mxmy = i_mxmy + rand2D(i_mxmy)*0.5+0.5;

    float2 points[9] = {rand_mxpy, rand_py, rand_pxpy,
                         rand_mx,   rand_o,  rand_px,
                         rand_mxmy, rand_my, rand_pxmy};
                     
    float dist = 100.0;
    [unroll]
    for(int i = 0; i < 9; i++){
        float d = length(pos - points[i]);
        dist = min(dist, d);
    }
    
    return dist / 1.41421356;
}

float cNoise(float3 pos){
    float3 i_o = floor(pos);
    //周辺のセル
    //p : plus ,  m : minus
    float3 i_px     = i_o + float3( 1,  0,  0);
    float3 i_py     = i_o + float3( 0,  1,  0);
    float3 i_pz     = i_o + float3( 0,  0,  1);
    float3 i_mx     = i_o + float3(-1,  0,  0);
    float3 i_my     = i_o + float3( 0, -1,  0);
    float3 i_mz     = i_o + float3( 0,  0, -1);//6
    float3 i_pxpz   = i_o + float3( 1,  0,  1);
    float3 i_mxpz   = i_o + float3(-1,  0,  1);
    float3 i_pxmz   = i_o + float3( 1,  0, -1);
    float3 i_mxmz   = i_o + float3(-1,  0, -1);//10
    float3 i_pxpy   = i_o + float3( 1,  1,  0);
    float3 i_pxmy   = i_o + float3( 1, -1,  0);
    float3 i_mxpy   = i_o + float3(-1,  1,  0);
    float3 i_mxmy   = i_o + float3(-1, -1,  0);//14
    float3 i_pypz   = i_o + float3( 0,  1,  1);
    float3 i_pymz   = i_o + float3( 0,  1, -1);
    float3 i_mypz   = i_o + float3( 0, -1,  1);
    float3 i_mymz   = i_o + float3( 0, -1, -1);
    float3 i_pxpypz = i_o + float3( 1,  1,  1);
    float3 i_mxpypz = i_o + float3(-1,  1,  1);
    float3 i_pxpymz = i_o + float3( 1,  1, -1);
    float3 i_mxpymz = i_o + float3(-1,  1, -1);//18
    float3 i_pxmypz = i_o + float3( 1, -1,  1);
    float3 i_mxmypz = i_o + float3(-1, -1,  1);
    float3 i_pxmymz = i_o + float3( 1, -1, -1);
    float3 i_mxmymz = i_o + float3(-1, -1, -1);//22
    
    float3 rand_o      = i_o      + rand3D(i_o) *0.5+0.5;
    float3 rand_px     = i_px     + rand3D(i_px)*0.5+0.5;
    float3 rand_mx     = i_mx     + rand3D(i_mx)*0.5+0.5;
    float3 rand_py     = i_py     + rand3D(i_py)*0.5+0.5;
    float3 rand_my     = i_my     + rand3D(i_my)*0.5+0.5;
    float3 rand_pz     = i_pz     + rand3D(i_pz)*0.5+0.5;
    float3 rand_mz     = i_mz     + rand3D(i_mz)*0.5+0.5;
    float3 rand_pxpy   = i_pxpy   + rand3D(i_pxpy)*0.5+0.5;
    float3 rand_pxmy   = i_pxmy   + rand3D(i_pxmy)*0.5+0.5;
    float3 rand_mxpy   = i_mxpy   + rand3D(i_mxpy)*0.5+0.5;
    float3 rand_mxmy   = i_mxmy   + rand3D(i_mxmy)*0.5+0.5;
    float3 rand_pxpz   = i_pxpz   + rand3D(i_pxpz)*0.5+0.5;
    float3 rand_pxmz   = i_pxmz   + rand3D(i_pxmz)*0.5+0.5;
    float3 rand_mxpz   = i_mxpz   + rand3D(i_mxpz)*0.5+0.5;
    float3 rand_mxmz   = i_mxmz   + rand3D(i_mxmz)*0.5+0.5;
    float3 rand_pymz   = i_pymz   + rand3D(i_pymz)*0.5+0.5;
    float3 rand_pypz   = i_pypz   + rand3D(i_pypz)*0.5+0.5;
    float3 rand_mypz   = i_mypz   + rand3D(i_mypz)*0.5+0.5;
    float3 rand_mymz   = i_mymz   + rand3D(i_mymz)*0.5+0.5;
    float3 rand_pxpypz = i_pxpypz + rand3D(i_pxpypz)*0.5+0.5;
    float3 rand_pxmymz = i_pxmymz + rand3D(i_pxmymz)*0.5+0.5;
    float3 rand_mxpypz = i_mxpypz + rand3D(i_mxpypz)*0.5+0.5;
    float3 rand_pxpymz = i_pxpymz + rand3D(i_pxpymz)*0.5+0.5;
    float3 rand_pxmypz = i_pxmypz + rand3D(i_pxmypz)*0.5+0.5;
    float3 rand_mxmypz = i_mxmypz + rand3D(i_mxmypz)*0.5+0.5;
    float3 rand_mxpymz = i_mxpymz + rand3D(i_mxpymz)*0.5+0.5;
    float3 rand_mxmymz = i_mxmymz + rand3D(i_mxmymz)*0.5+0.5;
    
    
    float3 points[27] = {rand_mxpypz, rand_pypz, rand_pxpypz,
                          rand_mxpy,   rand_py,   rand_pxpy,
                          rand_mxpymz, rand_pymz, rand_pxpymz,
                          
                          rand_mxpz,   rand_pz,   rand_pxpz,
                          rand_mx,     rand_o,    rand_px,
                          rand_mxmz,   rand_mz,   rand_pxmz,
                          
                          rand_mxmypz, rand_mypz, rand_pxmypz,
                          rand_mxmy,   rand_my,   rand_pxmy,
                          rand_mxmymz, rand_mymz, rand_pxmymz};
                     
    float dist = 100.0;
    [unroll]
    for(int i = 0; i < 27; i++){
        float d = length(pos - points[i]);
        dist = min(dist, d);
    }
    
    return dist / 1.7320508;
}

///Curl Noise

float2 curlNoise(float2 pos){
    const float epsilon = 0.00001;
    
    float2 n_px = pNoise2D(pos + float2(epsilon, 0));
    float2 n_mx = pNoise2D(pos - float2(epsilon, 0));
    float2 n_py = pNoise2D(pos + float2(0, epsilon));
    float2 n_my = pNoise2D(pos - float2(0, epsilon));

    float x = n_my.y - n_py.y;
    float y = n_px.x - n_mx.x;
    
    return normalize(float2(x,y));
}

float3 curlNoise(float3 pos){
    const float epsilon = 0.00001;
    
    float3 n_px = pNoise3D(pos + float3(epsilon, 0, 0));
    float3 n_mx = pNoise3D(pos - float3(epsilon, 0, 0));
    float3 n_py = pNoise3D(pos + float3(0, epsilon, 0));
    float3 n_my = pNoise3D(pos - float3(0, epsilon, 0));
    float3 n_pz = pNoise3D(pos + float3(0, 0, epsilon));
    float3 n_mz = pNoise3D(pos - float3(0, 0, epsilon));

    float x = n_my.z - n_py.z - n_mz.y + n_pz.y;
    float y = n_px.z - n_mx.z - n_pz.x + n_mz.x;
    float z = n_mx.y - n_px.y - n_my.x + n_py.x;
    
    return normalize(float3(x,y,z)/4.0);
}

///fBM

float fbm(float2 uv){
    float gain = 0.5;
    float freqIncrease = 2.0;
    float octaves = 5;
    
    //default value
    float amp = 0.5;
    float fre = 1.0;
    
    float ret = 0.0;//return
    
    for(int i = 0; i < octaves; i++){
        //任意のノイズを使う
        ret += valNoise(uv * fre) * amp;
        fre *= freqIncrease;
        amp *= gain;
    }
    return ret;
}

float fbm(float3 pos){
    float gain = 0.5;
    float freqIncrease = 2.0;
    float octaves = 5;
    
    //default value
    float amp = 0.5;
    float fre = 1.0;
    
    float ret = 0.0;//return
    
    for(int i = 0; i < octaves; i++){
        //任意のノイズを使う
        ret += valNoise(pos * fre) * amp;
        fre *= freqIncrease;
        amp *= gain;
    }
    return ret;
}






































