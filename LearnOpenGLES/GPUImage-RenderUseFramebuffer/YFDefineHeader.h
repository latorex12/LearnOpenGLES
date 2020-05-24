
//
//  YFDefineHeader.h
//  YFCamera
//
//  Created by apple on 2018/1/28.
//  Copyright © 2018年 yunfan.com. All rights reserved.
//

#ifndef YFDefineHeader_h
#define YFDefineHeader_h

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

#ifdef DEBUG
#define GL_ERRORS(line) { GLenum glerr; while((glerr = glGetError())) {\
switch(glerr)\
{\
case GL_NO_ERROR:\
break;\
case GL_INVALID_ENUM:\
DLog("OGL(" __FILE__ "):: %d: Invalid Enum\n", line );\
break;\
case GL_INVALID_VALUE:\
DLog("OGL(" __FILE__ "):: %d: Invalid Value\n", line );\
break;\
case GL_INVALID_OPERATION:\
DLog("OGL(" __FILE__ "):: %d: Invalid Operation\n", line );\
break;\
case GL_OUT_OF_MEMORY:\
DLog("OGL(" __FILE__ "):: %d: Out of Memory\n", line );\
break;\
} } }
#else
#define GL_ERRORS(line) {}
#endif

#ifdef DEBUG
#define DLog(...) printf(__VA_ARGS__);
#else
#define DLog(...) {}
#endif

#endif /* YFDefineHeader_h */
