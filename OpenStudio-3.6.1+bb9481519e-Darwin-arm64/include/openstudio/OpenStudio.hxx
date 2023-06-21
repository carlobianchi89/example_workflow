#ifndef OPENSTUDIO_HXX
#define OPENSTUDIO_HXX

// Support for Ninja on Windows (Ninja isn't multi-configuration while MSVC is)
#define NINJA

// Return the version in MAJOR.MINOR.PATCH format (eg '3.0.0')
inline std::string openStudioVersion()
{
  return "3.6.1";
}

// Includes prerelease tag if any, and build sha, eg: '3.0.0-rc1+baflkdhsia'
inline std::string openStudioLongVersion()
{
  return "3.6.1+bb9481519e";
}

inline std::string openStudioVersionMajor()
{
  return "3";
}

inline std::string openStudioVersionMinor()
{
  return "6";
}

inline std::string openStudioVersionPatch()
{
  return "1";
}

inline std::string openStudioVersionPrerelease()
{
  return "";
}

inline std::string openStudioVersionBuildSHA()
{
  return "bb9481519e";
}

inline int energyPlusVersionMajor()
{
  return 23;
}

inline int energyPlusVersionMinor()
{
  return 1;
}

inline int energyPlusVersionPatch()
{
  return 0;
}

inline std::string energyPlusVersion()
{
  return "23.1.0";
}

inline std::string energyPlusBuildSHA()
{
  return "87ed9199d4";
}

inline std::string rubyLibDir()
{
  return "/Users/julien/Software/Others/OpenStudio/ruby/";
}

inline std::string rubyOpenStudioDir()
{
  #ifdef WIN32
    #ifdef NINJA
      return "/Users/julien/Software/Others/OS-build-release/ruby/";
    #else
      return "/Users/julien/Software/Others/OS-build-release/ruby/" + std::string(CMAKE_INTDIR) + "/";
    #endif
  #else
    return "/Users/julien/Software/Others/OS-build-release/ruby/";
  #endif
}


#endif // OPENSTUDIO_HXX

