shader_type spatial;
render_mode unshaded, cull_disabled; // to raymarch in local space
//render_mode unshaded, world_vertex_coords, cull_disabled; // to raymarch in world space


//CONF
uniform vec3 domainScale = vec3(10.0);
uniform vec3 repeatLimit = vec3(2.0);
uniform bool doRepeat = false;
uniform bool debugNormal = false;
uniform vec3 sunpos = vec3(0.9, 1.0, 0.7);

// START SHAPES

uniform vec3 s1;
uniform float s1s;
uniform bool s1b = true;
uniform vec3 s2;
uniform float s2s;
uniform bool s2b = true;
uniform vec3 s3;
uniform float s3s;
uniform bool s3b = true;
uniform vec3 s4;
uniform float s4s;
uniform bool s4b = true;

uniform vec3 b1;
uniform float b1s;
uniform bool b1b = true;
uniform vec3 b2;
uniform float b2s;
uniform bool b2b = true;
uniform vec3 b3;
uniform float b3s;
uniform bool b3b = true;
uniform vec3 b4;
uniform float b4s;
uniform bool b4b = true;

// END SHAPES

varying vec3 world_camera;
varying vec3 world_position;

const int MAX_STEPS = 100;
const float MAX_DIST = 100.0;
const float GLOW_DIST = 75.0;
const float SURF_DIST = 1e-3;

float getSpheres(vec3 p){
	float o = MAX_DIST;
	
	vec3 spheres[] = {s1,s2,s3,s4};
	float scales[] = {s1s,s2s,s3s,s4s};
	bool bools[] = {s1b,s2b,s3b,s4b};
	int count = 4;
	for(int i=0; i < count;i += 1){
		vec3 transform = spheres[i];
		float scale = scales[i];
		bool mode = bools[i];
		if(scale != 0.0){
			float d = length(p - transform) - scale; //Sphere
			if(mode){
				o = min(o, d);
			}
			else{
				o = max(o, -d);
			}
		}
	}
	return o;
}

float getBoxes(vec3 p){
	float o = MAX_DIST;
	
	vec3 boxes[] = {b1, b2, b3, b4};
	float scales[] = {b1s, b2s, b3s, b4s};
	bool bools[] = {b1b, b2b, b3b, b4b};
	int count = 4;
	for(int i=0; i < count;i += 1){
		vec3 transform = boxes[i];
		float scale = scales[i];
		bool mode = bools[i];
		if(scale != 0.0){
			float b = scale/2.0;
			vec3 q = abs(p-transform) - b;
  			float d = length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
			if(mode){
				o = min(o, d);
			}
			else{
				o = max(o, -d);
			}
		}
	}
	return o;
}

vec3 repeat(vec3 p, vec3 c){
	vec3 q = mod(p+0.5*c,c)-0.5*c;
	return q;
}
vec3 limitedRepeat(vec3 p, vec3 c, vec3 limit){
	vec3 q = p-c*clamp(round(p/c),-limit,limit);
	return q;
}
float GetDist(vec3 p){
//	float d = length(p) - .5; //Sphere
//	d = length(vec2(length(p.xz) - .5, p.y)) - .1; //torus
	vec3 q = p;
	if(doRepeat){
		q = limitedRepeat(p, domainScale, repeatLimit);
		
	}
	float d = MAX_DIST;
	d = min(d, getBoxes(q));
	d = min(d, getSpheres(q));
	return d;
}




float RayMarch(vec3 ro, vec3 rd) {
	float dO = 0.0;
	float dS;
	float steps = float(MAX_STEPS);
	
	for (int i = 0; i < MAX_STEPS; i++)
	{
		vec3 p = ro + dO * rd;
		dS = GetDist(p);
		dO += dS;
		
		if (dS < SURF_DIST || dO > MAX_DIST){
			steps = float(i);
			break;
		}
	}
	return dO;
}
int RayMarchSteps(vec3 ro, vec3 rd) {
	float dO = 0.0;
	float dS;
	float retur[2];
	int steps = MAX_STEPS;
	
	for (int i = 0; i < MAX_STEPS; i++)
	{
		vec3 p = ro + dO * rd;
		dS = GetDist(p);
		dO += dS;
		
		if (dS < SURF_DIST || dO > MAX_DIST){
			steps = i;
			break;
		}
	}
	return steps;
}
vec3 GetNormal(vec3 p) {
	vec2 e = vec2(1e-2, 0);
	
	vec3 n = GetDist(p) - vec3(
		GetDist(p - e.xyy),
		GetDist(p - e.yxy),
		GetDist(p - e.yyx)
	);
	
	return normalize(n);
}

void vertex() {
	world_position = VERTEX;
	world_camera = (inverse(MODELVIEW_MATRIX) * vec4(0, 0, 0, 1)).xyz; //object space
	//world_camera = ( CAMERA_MATRIX  * vec4(0, 0, 0, 1)).xyz; //uncomment this to raymarch in world space
}

void fragment() {
	
	vec3 ro = world_camera;
	vec3 rd =  normalize(world_position - ro);
	
	vec3 col;
	
	float d = RayMarch(ro, rd);

	if (d >= MAX_DIST){
		discard;
	}
	else
	{
		int steps = RayMarchSteps(ro, rd);
		vec3 p = ro + rd * d;
		vec3 n = GetNormal(p);
		vec3 refnorm = reflect(rd, n);
		vec3 upnorm = normalize( sunpos );
		
		if (debugNormal){
			col = (n).rgb;
		}
		else{
			float fresnel = sqrt(1.0 - dot(n, VIEW));
			// Reflection pass 1
			float reflection = RayMarch(p + n*0.003, refnorm);
			float gi = RayMarch(p + n*0.003, upnorm);
			// Reflection pass 2
			vec3 rp = (p + n*0.003) + reflect(rd, n) * reflection;
			vec3 rn = GetNormal(rp);
			float reflection2= RayMarch(rp + rn*0.003, reflect(refnorm, rn));
			float refgi = RayMarch(rp + rn*0.003, upnorm);
			if(refgi >= MAX_DIST){
				refgi = 1.0;
			}
			if(reflection2 >= MAX_DIST){
				//reflection2 = 1.0;
			}
			if(reflection2 < 0.0){
				reflection2 = 0.0;
			}
			//
			col = p;
			col = vec3(.6, .9, 1.0);
			col *= clamp(1.0+(float(steps)*0.0125*0.5), 1.0, 1.5);
			//COL2
			vec3 col2 = vec3(.6, .9, 1.0);
			float refgi_f = (0.0 + (clamp( refgi, 1.0, 100.0 )/ 100.0)) * 1.0;
			col2 *= (col2 + vec3(refgi_f))/1.0;
			//col2 += (vec3(clamp(reflection2, 0.0, 100.0))*col2)/100.0;
			//END COL2
			col += (vec3(clamp(reflection, 0.0, 100.0))*col2)/200.0;
//			col -= clamp(vec3( (1.0 - (clamp( reflection, 0.1, 100.0 )/ 100.0)) *0.1 ), 0.0, 0.5); // Pass 1
	//		col -= vec3( (1.0 - (clamp( reflection2, 0.1, 1000.0 )/ 1000.0)) *0.1 ); // Pass 2
			col += clamp(vec3(1.0, 1.0, 1.0) * (d/50.0), 0.0, 1.0); //fog
	//		col *= (1.0-vec3( float(steps/MAX_STEPS) )); //"AO"
	//		RIM = 0.2;
	//		METALLIC = 1.0;
	//		ROUGHNESS = 0.01 * (1.0 - fresnel);
	//		col = (vec3(0.01, 0.03, 0.05) + (0.1 * fresnel)).rgb;
			//col = vec3(reflection2);
			
			float gi_f = (0.0 + (clamp( gi, 1.0, 100.0 )/ 100.0)) * 1.0;
			col *= (col + vec3(gi_f))/3.0;
		}
	}
	ALBEDO = col;
}