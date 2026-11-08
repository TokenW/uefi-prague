## @file
#  prague.dsc
#
#  Prague (Redmi K90 Max) UEFI firmware DSC
#  SoC: MediaTek MT6993 (Dimensity 9500)
#
##

[Defines]
  PLATFORM_NAME           = prague
  PLATFORM_GUID           = 12345678-1234-1234-1234-123456789012
  PLATFORM_VERSION        = 0.1
  DSC_SPECIFICATION       = 0x00010005
  OUTPUT_DIRECTORY        = Build/praguePkg
  SUPPORTED_ARCHITECTURES = AARCH64
  BUILD_TARGETS           = DEBUG|RELEASE
  SKUID_IDENTIFIER        = DEFAULT

  #
  #  Platform configuration
  #
  gPragueTokenSpaceGuid.PcdFirmwareVendor            = L"UniXNU"
  gPragueTokenSpaceGuid.PcdFirmwareVersionString     = L"prague UEFI v0.1"

[PcdsFeatureFlag]
  gEfiMdeModulePkgTokenSpaceGuid.PcdInstallAcpiSdtProtocol = TRUE

[LibraryClasses.common]
  #
  #  UniXNU required libraries
  #
  HobLib|MdePkg/Library/DxeHobLib/DxeHobLib.inf
  FdtLib|MdePkg/Library/BaseFdtLib/BaseFdtLib.inf

  #
  #  Base libraries
  #
  BaseLib|MdePkg/Library/BaseLib/BaseLib.inf
  BaseMemoryLib|MdePkg/Library/BaseMemoryLib/BaseMemoryLib.inf
  DebugLib|MdePkg/Library/BaseDebugLibSerialPort/BaseDebugLibSerialPort.inf
  DebugPrintErrorLevelLib|MdePkg/Library/BaseDebugPrintErrorLevelLib/BaseDebugPrintErrorLevelLib.inf
  MemoryAllocationLib|MdePkg/Library/UefiMemoryAllocationLib/UefiMemoryAllocationLib.inf
  PrintLib|MdePkg/Library/BasePrintLib/BasePrintLib.inf
  TimerLib|MdePkg/Library/BaseTimerLib/BaseTimerLib.inf
  UefiBootServicesTableLib|MdePkg/Library/UefiBootServicesTableLib/UefiBootServicesTableLib.inf
  UefiDriverEntryPoint|MdePkg/Library/UefiDriverEntryPoint/UefiDriverEntryPoint.inf
  UefiLib|MdePkg/Library/UefiLib/UefiLib.inf
  UefiRuntimeServicesTableLib|MdePkg/Library/UefiRuntimeServicesTableLib/UefiRuntimeServicesTableLib.inf

  #
  #  Serial port for debug output
  #
  SerialPortLib|MdePkg/Library/BaseSerialPortLib/BaseSerialPortLib.inf

[Components.common]
  #
  #  UniXNU required modules
  #
  UniXNUPkg/Application/UniXNU/UniXNU.inf
  UniXNUPkg/Driver/UniXNUDxe/UniXNUDxe.inf
  UniXNUPkg/Driver/UniXNURamDiskDxe/UniXNURamDiskDxe.inf
  DarwinBootPkg/Driver/DarwinBoot.inf

  #
  #  Filesystem support for payload
  #
  MdeModulePkg/Universal/Disk/DiskIoDxe/DiskIoDxe.inf
  FatPkg/EnhancedFatDxe/Fat.inf

  #
  #  Platform drivers (TODO: implement)
  #
  # MT6993Pkg/Driver/GicDxe/GicDxe.inf
  # MT6993Pkg/Driver/SerialPortDxe/SerialPortDxe.inf
  # MT6993Pkg/Driver/DisplayDxe/DisplayDxe.inf
  # MT6993Pkg/Driver/UfsDxe/UfsDxe.inf

[BuildOptions]
  RELEASE_*_*_CC_FLAGS  = -DMDEPKG_NDEBUG
