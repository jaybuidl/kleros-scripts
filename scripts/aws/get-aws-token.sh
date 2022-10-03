#!/usr/bin/env ansible-playbook -c local
#/usr/bin/ansible-playbook
#
# AWS STS token update playbook.
#
# Updating AWS session tokens with STS can be a pain. But MFA is good. So let's
# automate the management of the .aws/credentials file to make it not painful!
#
# Usage:
#
#  1. Save this to a file like /usr/local/bin/aws-sts-token
#  2. Make the file executable (chmod +x /usr/local/bin/aws-sts-token)
#  3. Run the command:
#
#        ./aws-sts-token -e aws_userarn=ARN_FROM_IAM -e aws_profile=PROFILE -e aws_sts_profile=STS_PROFILE -e token_code=TOKEN
#
# Options:
#   - ARN_FROM_IAM: Your AWS user account ARN, like "arn:aws:iam::241312619141:mfa/johndoe"
#   - PROFILE: AWS credentials profile, like "personal"
#   - STS_PROFILE: AWS credentials profile for STS, like "default"
#   - TOKEN: One-time token from your MFA device
#
---
- hosts: localhost
  become: no
  gather_facts: no

  vars:
    aws_userarn: ''
    aws_profile: ''
    aws_sts_profile: ''
    token_code: ''

  tasks:
    - name: Get STS session token.
      command: aws sts get-session-token --serial-number {{ aws_userarn }} --profile {{ aws_profile }} --token-code {{ token_code }} --duration-seconds 14400
      register: sts_session_creds

    - debug: var=(sts_session_creds.stdout|from_json)

    - name: Print session token.
      set_fact:
        secret_access_key: "{{ (sts_session_creds.stdout|from_json)['Credentials']['SecretAccessKey'] }}"
        session_token: "{{ (sts_session_creds.stdout|from_json)['Credentials']['SessionToken'] }}"
        access_key_id: "{{ (sts_session_creds.stdout|from_json)['Credentials']['AccessKeyId'] }}"
        expiration: "{{ (sts_session_creds.stdout|from_json)['Credentials']['Expiration'] }}"

    - name: Print token expiration date
      debug:
        msg: "Token expires at {{ expiration }}"

    - name: Print all the credentials for debug (only with -vv).
      debug:
        var: "{{ item }}"
        verbosity: 2
      with_items:
        - access_key_id
        - secret_access_key
        - session_token

    - name: Update credentials in .aws/credentials file.
      blockinfile:
        path: ~/.aws/credentials
        marker: "# ANSIBLE MANAGED PROFILE: {{ aws_sts_profile }} {mark}"
        insertafter: EOF
        backup: yes
        block: |
          [{{ aws_sts_profile }}]
          aws_access_key_id={{ access_key_id }}
          aws_secret_access_key={{ secret_access_key }}
          aws_session_token={{ session_token }}

    - name: Set the same region for the STS profile
      shell: |
        r=$(aws configure get region --profile aqt-dev)
        aws configure set region "$r" --profile aqt-dev-sts
      args:
        executable: /bin/bash
