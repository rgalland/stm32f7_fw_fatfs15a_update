[#ftl]
/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file    sdram_diskio.c (based on sdram_diskio_template.c v2.0.2)
  * @brief   SDRAM Disk I/O driver
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+"/license.tmp"/][#--include License text --]
  ******************************************************************************
  */
/* USER CODE END Header */
/* USER CODE BEGIN firstSection */ 
/* can be used to modify / undefine following code or add new definitions */
/* USER CODE END firstSection */ 

/* Includes ------------------------------------------------------------------*/
#include "ff_gen_drv.h"
#include "sdram_diskio.h"


/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Block Size in Bytes */
#define BLOCK_SIZE                512

/* Private variables ---------------------------------------------------------*/
/* Disk status */
static volatile DSTATUS Stat = STA_NOINIT;

/* Private function prototypes -----------------------------------------------*/
DSTATUS SDRAMDISK_initialize (BYTE);
DSTATUS SDRAMDISK_status (BYTE);
DRESULT SDRAMDISK_read (BYTE, BYTE*, DWORD, UINT);
DRESULT SDRAMDISK_write (BYTE, const BYTE*, DWORD, UINT);
DRESULT SDRAMDISK_ioctl (BYTE, BYTE, void*);

const Diskio_drvTypeDef  SDRAMDISK_Driver =
{
  SDRAMDISK_initialize,
  SDRAMDISK_status,
  SDRAMDISK_read,
  SDRAMDISK_write,
  SDRAMDISK_ioctl,
};

/* USER CODE BEGIN beforeFunctionSection */
/* can be used to modify / undefine following code or add new code */
/* USER CODE END beforeFunctionSection */

/* Private functions ---------------------------------------------------------*/

/**
  * @brief  Initializes a Drive
  * @param  lun : not used
  * @retval DSTATUS: Operation status
  */
DSTATUS SDRAMDISK_initialize(BYTE lun)
{
  Stat = STA_NOINIT;

  /* Configure the SDRAM device */
  if(BSP_SDRAM_Init() == SDRAM_OK)
  {
    Stat &= ~STA_NOINIT;
  }

  return Stat;
}

/**
  * @brief  Gets Disk Status
  * @param  lun : not used
  * @retval DSTATUS: Operation status
  */
DSTATUS SDRAMDISK_status(BYTE lun)
{
  return Stat;
}

/* USER CODE BEGIN beforeReadSection */
/* can be used to modify previous code / undefine following code / add new code */
/* USER CODE END beforeReadSection */

/**
  * @brief  Reads Sector(s)
  * @param  lun : not used
  * @param  *buff: Data buffer to store read data
  * @param  sector: Sector address (LBA)
  * @param  count: Number of sectors to read (1..128)
  * @retval DRESULT: Operation result
  */
DRESULT SDRAMDISK_read(BYTE lun, BYTE *buff, DWORD sector, UINT count)
{
  uint32_t *pSrcBuffer = (uint32_t *)buff;
  uint32_t BufferSize = (BLOCK_SIZE * count)/4;
  uint32_t *pSdramAddress = (uint32_t *) (SDRAM_DEVICE_ADDR + (sector * BLOCK_SIZE));

  for(; BufferSize != 0; BufferSize--)
  {
    *pSrcBuffer++ = *(__IO uint32_t *)pSdramAddress++;
  }

  return RES_OK;
}

/* USER CODE BEGIN beforeWriteSection */
/* can be used to modify previous code / undefine following code / add new code */
/* USER CODE END beforeWriteSection */

/**
  * @brief  Writes Sector(s)
  * @param  lun : not used
  * @param  *buff: Data to be written
  * @param  sector: Sector address (LBA)
  * @param  count: Number of sectors to write (1..128)
  * @retval DRESULT: Operation result
  */
DRESULT SDRAMDISK_write(BYTE lun, const BYTE *buff, DWORD sector, UINT count)
{
  uint32_t *pDstBuffer = (uint32_t *)buff;
  uint32_t BufferSize = (BLOCK_SIZE * count)/4;
  uint32_t *pSramAddress = (uint32_t *) (SDRAM_DEVICE_ADDR + (sector * BLOCK_SIZE));

  for(; BufferSize != 0; BufferSize--)
  {
    *(__IO uint32_t *)pSramAddress++ = *pDstBuffer++;
  }

  return RES_OK;
}

/* USER CODE BEGIN beforeIoctlSection */
/* can be used to modify previous code / undefine following code / add new code */
/* USER CODE END beforeIoctlSection */

/**
  * @brief  I/O control operation
  * @param  lun : not used
  * @param  cmd: Control code
  * @param  *buff: Buffer to send/receive control data
  * @retval DRESULT: Operation result
  */
DRESULT SDRAMDISK_ioctl(BYTE lun, BYTE cmd, void *buff)
{
  DRESULT res = RES_ERROR;

  if (Stat & STA_NOINIT) return RES_NOTRDY;

  switch (cmd)
  {
  /* Make sure that no pending write process */
  case CTRL_SYNC :
    res = RES_OK;
    break;

  /* Get number of sectors on the disk (DWORD) */
  case GET_SECTOR_COUNT :
    *(DWORD*)buff = SDRAM_DEVICE_SIZE / BLOCK_SIZE;
    res = RES_OK;
    break;

  /* Get R/W sector size (WORD) */
  case GET_SECTOR_SIZE :
    *(WORD*)buff = BLOCK_SIZE;
    res = RES_OK;
    break;

  /* Get erase block size in unit of sector (DWORD) */
  case GET_BLOCK_SIZE :
    *(DWORD*)buff = 1;
	res = RES_OK;
    break;

  default:
    res = RES_PARERR;
  }

  return res;
}

/* USER CODE BEGIN lastSection */ 
/* can be used to modify / undefine previous code or add new code */
/* USER CODE END lastSection */ 
  
