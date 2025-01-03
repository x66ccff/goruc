import os
import requests

# 取消代理设置
os.environ.pop('http_proxy', None)
os.environ.pop('https_proxy', None)
os.environ.pop('HTTP_PROXY', None)
os.environ.pop('HTTPS_PROXY', None)
os.environ.pop('all_proxy', None)
os.environ.pop('ALL_PROXY', None)
os.environ.pop('SOCKS_PROXY', None)
os.environ.pop('socks_proxy', None)

# 测试标志
is_test_no_network = False

# 测试网络连通性
test_sites = [
    'https://www.baidu.com',
    'https://www.taobao.com',
    'https://www.jd.com',
    'https://www.163.com',
    'https://www.qq.com',
    'https://www.zhihu.com',
    'https://www.bilibili.com',
    'https://www.weibo.com',
    'https://www.douyin.com',
    'https://www.tmall.com',
    'https://www.alipay.com',
    'https://www.csdn.net',
    'https://www.bing.com',
    'https://www.360.cn',
    'https://www.sohu.com'
]

if not is_test_no_network:
    for site in test_sites:
        try:
            response = requests.get(site, timeout=5, proxies={
                'http': None,
                'https': None
            })
            if response.status_code == 200:
                print(f"可以访问 {site}，网络正常，无需登录")
                exit(0)
        except Exception as e:
            print(f"无法访问 {site}: {e}")
            continue
    
    print("所有测试网站均无法访问，确认需要登录校园网")

import asyncio
import logging
from playwright.async_api import async_playwright

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def login_ruc():
    logger.info("开始运行自动登录程序...")
    
    async with async_playwright() as p:
        # 启动浏览器
        logger.info("正在启动浏览器...")
        browser = await p.chromium.launch(
            headless=True,  # 无头模式
        )
        
        # 创建新页面
        page = await browser.new_page()
        
        try:
            # 访问登录页面
            logger.info("正在访问 go.ruc.edu.cn...")
            await page.goto('https://go.ruc.edu.cn')
            
            # 输入登录信息
            username = os.environ.get('RUC_ID')
            password = os.environ.get('RUC_KEY')
            
            # 检查密码是否存在
            if not password:
                logger.error("未设置 RUC_KEY 环境变量")
                raise ValueError("请先设置 RUC_KEY 环境变量")
            
            logger.info("正在输入登录信息...")
            await page.fill('#username', username)
            await page.fill('#password', password)
            
            # 点击登录按钮
            logger.info("正在点击登录按钮...")
            await page.click('#login-account')
            
            # 等待登录完成
            logger.info("等待登录完成...")
            await page.wait_for_timeout(5000)  # 等待5秒
            
            # 打印页面信息
            print(await page.title())
            print(await page.content())
            
        except Exception as e:
            logger.error(f"发生错误: {str(e)}")
            raise
        finally:
            # 关闭浏览器
            logger.info("正在关闭浏览器...")
            await browser.close()

# 运行主程序
if __name__ == "__main__":
    asyncio.run(login_ruc())
