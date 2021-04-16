#!/usr/bin/env bash
# Author: Habib Guliyev | 16.04.21
# Default Nexus Variables:
Nexus_IP="localhost"
Nexus_Port="8081"
Nexus_Username="admin"
Nexus_Password="admin123"
Nexus_BlobStore="default"
# Tasks description vars:
firstTaskDesc='Docker - Delete unused manifests and images'
secondTaskDesc="Compacting ${NEXUS_BLOB:-$Nexus_BlobStore} blob store"
# Global Functions:
# Get Tasks ID via their descriptions
function getTaskInfo(){
    TasksCount=$(curl -s -u "${NEXUS_USER:-$Nexus_Username}:${NEXUS_PASS:-$Nexus_Password}" -X GET "http://${NEXUS_IP:-$Nexus_IP}:${NEXUS_PORT:-$Nexus_Port}/service/rest/v1/tasks"|jq -r .items[].message|wc -l)
    for task in $(seq 0 $(expr $TasksCount - 1))
    do
        TaskMessage=$(curl -s -u "${NEXUS_USER:-$Nexus_Username}:${NEXUS_PASS:-$Nexus_Password}" -X GET "http://${NEXUS_IP:-$Nexus_IP}:${NEXUS_PORT:-$Nexus_Port}/service/rest/v1/tasks"|jq -r .items[$task].message)
        if [ "$TaskMessage" == "$firstTaskDesc" ]
        then
            deleteUnusedManifestsAndImages="$(curl -s -u "${NEXUS_USER:-$Nexus_Username}:${NEXUS_PASS:-$Nexus_Password}" -X GET "http://${NEXUS_IP:-$Nexus_IP}:${NEXUS_PORT:-$Nexus_Port}/service/rest/v1/tasks"|jq -r .items[$task].id)"
        elif [ "$TaskMessage" == "$secondTaskDesc" ]
        then
            compactBlobStore="$(curl -s -u "${NEXUS_USER:-$Nexus_Username}:${NEXUS_PASS:-$Nexus_Password}" -X GET "http://${NEXUS_IP:-$Nexus_IP}:${NEXUS_PORT:-$Nexus_Port}/service/rest/v1/tasks"|jq -r .items[$task].id)"
        fi
    done
}
# Execute First Task
function deleteUnusedManifestsAndImages() {
    printf "\rSTARTED | Task: $firstTaskDesc"
    curl -s -u "${NEXUS_USER:-$Nexus_Username}:${NEXUS_PASS:-$Nexus_Password}" -X POST "http://${NEXUS_IP:-$Nexus_IP}:${NEXUS_PORT:-$Nexus_Port}/service/rest/v1/tasks/$deleteUnusedManifestsAndImages/run"
    lo=1 ; pr="/-\|" ; echo -n 'Waiting: '
    while true
    do
        currentState=$(curl -s -u "${NEXUS_USER:-$Nexus_Username}:${NEXUS_PASS:-$Nexus_Password}" -X GET "http://${NEXUS_IP:-$Nexus_IP}:${NEXUS_PORT:-$Nexus_Port}/service/rest/v1/tasks/$deleteUnusedManifestsAndImages" | jq -r .currentState)
        lastRunResult=$(curl -s -u "${NEXUS_USER:-$Nexus_Username}:${NEXUS_PASS:-$Nexus_Password}" -X GET "http://${NEXUS_IP:-$Nexus_IP}:${NEXUS_PORT:-$Nexus_Port}/service/rest/v1/tasks/$deleteUnusedManifestsAndImages" | jq -r .lastRunResult)
        if [[ "$currentState" == 'WAITING' && "$lastRunResult" == 'OK' ]]
        then
            printf "\rFINISHED | Task: $firstTaskDesc"
            break
        fi && printf "\b${pr:lo++%${#pr}:1}" && sleep 1
    done && echo
}
# Execute Second Task
function compactBlobStore() {
    printf "\rSTARTED | Task: $secondTaskDesc"
    curl -s -u "${NEXUS_USER:-$Nexus_Username}:${NEXUS_PASS:-$Nexus_Password}" -X POST "http://${NEXUS_IP:-$Nexus_IP}:${NEXUS_PORT:-$Nexus_Port}/service/rest/v1/tasks/$compactBlobStore/run"
    lo=1 ; pr="/-\|" ; echo -n 'Waiting: '
    while true
    do
        currentState=$(curl -s -u "${NEXUS_USER:-$Nexus_Username}:${NEXUS_PASS:-$Nexus_Password}" -X GET "http://${NEXUS_IP:-$Nexus_IP}:${NEXUS_PORT:-$Nexus_Port}/service/rest/v1/tasks/$compactBlobStore" | jq -r .currentState)
        lastRunResult=$(curl -s -u "${NEXUS_USER:-$Nexus_Username}:${NEXUS_PASS:-$Nexus_Password}" -X GET "http://${NEXUS_IP:-$Nexus_IP}:${NEXUS_PORT:-$Nexus_Port}/service/rest/v1/tasks/$compactBlobStore" | jq -r .lastRunResult)
        if [[ "$currentState" == 'WAITING' && "$lastRunResult" == 'OK' ]]
        then
            printf "\rFINISHED | Task: $secondTaskDesc"
            break
        fi && printf "\b${pr:lo++%${#pr}:1}" && sleep 1
    done && echo
}
# Call Functions
getTaskInfo
deleteUnusedManifestsAndImages && compactBlobStore