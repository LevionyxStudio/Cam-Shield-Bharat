import httpx
import time
import json
import sys
import os

sys.stdout.reconfigure(encoding='utf-8')

test_cases = [
    {
        'id': '1_bank_otp',
        'title': 'Bank Account Suspension + OTP Request',
        'payload': {
            'message': 'Your HDFC bank account has been suspended due to unverified KYC. Send your 6-digit OTP immediately to unlock your account.',
            'input_type': 'sms',
            'language': 'en'
        }
    },
    {
        'id': '2_kyc_link',
        'title': 'Suspicious KYC Update with Phishing Link',
        'payload': {
            'message': 'Dear customer, your SBI NetBanking will expire today. Update your PAN card and KYC immediately by visiting http://sbi-kyc-update-portal.xyz/verify',
            'input_type': 'sms',
            'language': 'en'
        }
    },
    {
        'id': '3_lottery_fee',
        'title': 'Fake Prize / Lottery with Advance Payment',
        'payload': {
            'message': 'Congratulations! You have won Rs 25,00,000 in the KBC Lucky Draw 2026. To claim your prize money, deposit Rs 5,500 registration fee to UPI ID kbcwinner@okaxis.',
            'input_type': 'whatsapp',
            'language': 'en'
        }
    },
    {
        'id': '4_harmless_dinner',
        'title': 'Normal Harmless Message',
        'payload': {
            'message': "Hi Mom, I reached the office safely. Let's have dinner together tonight around 8 PM.",
            'input_type': 'sms',
            'language': 'en'
        }
    },
    {
        'id': '5_hindi_hinglish',
        'title': 'Hinglish Account Freeze Scam',
        'payload': {
            'message': 'Aapka HDFC bank account block ho gaya hai. Turant unblock karne ke liye customer care ko apna 6-digit OTP share karein.',
            'input_type': 'sms',
            'language': 'hinglish'
        }
    },
    {
        'id': '6_no_obvious_scam',
        'title': 'Message with No Obvious Scam Indicators',
        'payload': {
            'message': "Hi Rahul, can you share the presentation slides from yesterday's team meeting?",
            'input_type': 'text',
            'language': 'en'
        }
    }
]

url = 'http://127.0.0.1:8000/api/analyze/message'

print('=' * 80)
print('RUNNING REAL SCAM DETECTION TESTS AGAINST FASTAPI BACKEND')
print('=' * 80)

results = []
for case in test_cases:
    print(f"\n---> Testing Case: {case['title']}")
    t0 = time.perf_counter()
    resp = httpx.post(url, json=case['payload'], timeout=40.0)
    latency = time.perf_counter() - t0
    status = resp.status_code
    data = resp.json() if status == 200 else resp.text
    
    res = {
        'id': case['id'],
        'title': case['title'],
        'status_code': status,
        'latency_s': round(latency, 2),
        'data': data
    }
    results.append(res)
    print(f"Status: {status} | Latency: {latency:.2f}s")
    if status == 200:
        print(f"  Scam Type: {data.get('scam_type')}")
        print(f"  Verdict: {data.get('verdict')} | Risk Score: {data.get('risk_score')} ({data.get('risk_level')})")
        print(f"  Provider: {data.get('ai_provider')} (model: {data.get('model_name')}, fallback: {data.get('fallback_used')})")
        print(f"  Summary: {data.get('summary')}")
        rf_count = len(data.get('red_flags') or [])
        print(f"  Red Flags: {rf_count} detected")
        actions = data.get('recommended_actions') or []
        print(f"  Actions: {actions[:2]}")
    else:
        print(f"  ERROR: {data}")

os.makedirs('tests_output', exist_ok=True)
with open('tests_output/scam_detection_results.json', 'w', encoding='utf-8') as f:
    json.dump(results, f, indent=2, ensure_ascii=False)
print('\nResults saved to tests_output/scam_detection_results.json')
