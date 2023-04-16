import requests
from selenium import webdriver
from selenium.webdriver.common.by import By

import wget
import time
from selenium_stealth import stealth

import requests
import shutil

def get_icon_url():
    # Get the icon url from the name of the app
    # Return the url of the icon

    options = webdriver.ChromeOptions()
    options.add_argument("start-maximized")

    # options.add_argument("--headless")

    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option('useAutomationExtension', False)


    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_argument("--disable-extensions")
    options.add_experimental_option('useAutomationExtension', False)
    options.add_experimental_option("excludeSwitches", ["enable-automation"])

    driver = webdriver.Chrome(options=options)
    driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")

    url = "https://www.olx.com.eg/en/vehicles/cars-for-sale/brilliance/cairo/?filter=new_used_eq_2%2Cyear_between_2000_to_2023"
    driver.get(url)

    time.sleep(5)

    allIcons = driver.find_element(By.CSS_SELECTOR, "div._28a1a731:nth-child(4) > div:nth-child(2)")
    allIcons = allIcons.find_elements(By.TAG_NAME, "img")
    for icon in allIcons:
        text(icon)
    
    print(len(allIcons))
    driver.close()

def text(icon):
    print(icon.get_attribute('src'))
    response = requests.get(icon.get_attribute('src'), stream=True)
    local_filename = icon.get_attribute("Title") + ".png"
    with open(local_filename, 'wb') as out_file:
        shutil.copyfileobj(response.raw, out_file)
    del response
    print(local_filename)

get_icon_url()

# rename all brands to brand.png

