/*
 * Authors: T. Heim <timon.heim@cern.ch>,
 * Date: 2013-Oct-22
 */

#include "Fei4TriggerLoop.h"
#include <unistd.h>

Fei4TriggerLoop::Fei4TriggerLoop() : LoopActionBase() {
    m_trigCnt = 50; // Maximum numberof triggers to send
    m_trigDelay = 33; // Delay between injection and trigger
    m_trigFreq = 1e3; // 1kHz
    m_trigTime = 10; // 10s
    m_trigWord[0] = 0x00;
    m_trigWord[1] = TRIG_CMD;
    m_trigWord[2] = 0x00;
    m_trigWord[3] = CAL_CMD;
    isInner = false;
    min = 0;
    max = 0;
    step = 1;
    loopType = typeid(this);
}

void Fei4TriggerLoop::init() {
    m_done = false;
    if (verbose)
        std::cout << __PRETTY_FUNCTION__ << std::endl;
    // Setup Trigger
    if (m_trigCnt > 0) {
        g_tx->setTrigConfig(INT_COUNT);
    } else {
        g_tx->setTrigConfig(INT_TIME);
    }
    g_tx->setTrigFreq(m_trigFreq);
    g_tx->setTrigCnt(m_trigCnt);
    g_tx->setTrigWordLength(m_trigWordLength);
    g_tx->setTrigWord(m_trigWord);
    g_tx->setTrigTime(m_trigTime);
    // Set active Modules into runmode
    // TODO ISSUE: This makes problems
    /*for (unsigned i=0; i<keeper->feList.size(); i++) {
        if (keeper->feList[i]->isActive()) {
            std::cout << "Tx = " << (0x1 << keeper->feList[i]->getTxChannel()) << std::endl;
            g_tx->setCmdEnable(0x1 << keeper->feList[i]->getTxChannel());
            keeper->feList[i]->setRunMode(true);
            usleep(100);
            while(!g_tx->isCmdEmpty());
        }
    }*/

    // Workaround: Put everything into run mode, active rx channels will sort this out
    g_tx->setCmdEnable(keeper->getTxMask());
    g_fe->setRunMode(true);
    usleep(100); // Empty could be delayed
    while(!g_tx->isCmdEmpty());
}

void Fei4TriggerLoop::end() {
    if (verbose)
        std::cout << __PRETTY_FUNCTION__ << std::endl;
    // Go back to conf mode, general state of FE should be conf mode
    g_fe->setRunMode(false);
    while(!g_tx->isCmdEmpty());
}

void Fei4TriggerLoop::execPart1() {
    if (verbose)
        std::cout << __PRETTY_FUNCTION__ << std::endl;
    // Enable Trigger
    g_tx->setTrigEnable(0x1);
}

void Fei4TriggerLoop::execPart2() {
    if (verbose)
        std::cout << __PRETTY_FUNCTION__ << std::endl;
    while(!g_tx->isTrigDone());
    // Disable Trigger
    g_tx->setTrigEnable(0x0);
    m_done = true;
}

void Fei4TriggerLoop::setTrigCnt(unsigned int cnt) {
    m_trigCnt = cnt;
}

unsigned int Fei4TriggerLoop::getTrigCnt() {
    return m_trigCnt;
}

void Fei4TriggerLoop::setTrigDelay(unsigned int delay) {
    unsigned pos = (delay-1)%32; // subtract 8 bit long trig cmd
    unsigned word = (delay-1)/32; // Select word in array
    m_trigWord[0] = 0;
    m_trigWord[1] = 0;
    m_trigWord[2] = 0;
    m_trigWord[3] = CAL_CMD;
    if ((word < 3 && pos <= 27) || word < 2) {
        m_trigWord[2-word] = (TRIG_CMD>>pos);
        if (pos > 27) // In case we shifted over word border
            m_trigWord[2-1-word] = (TRIG_CMD<<(5-(32-pos)));
        m_trigDelay = delay;
    }
    m_trigWordLength = 32 + delay;
}

void Fei4TriggerLoop::setNoInject() {
    m_trigWord[0] = 0;
    m_trigWord[1] = 0;
    m_trigWord[2] = 0;
    m_trigWord[3] = TRIG_CMD;
    m_trigWordLength = 5;
}

unsigned int Fei4TriggerLoop::getTrigDelay() {
    return m_trigDelay;
}

void Fei4TriggerLoop::setTrigFreq(double freq) {
    m_trigFreq = freq;
}

double Fei4TriggerLoop::getTrigFreq() {
    return m_trigFreq;
}

void Fei4TriggerLoop::setTrigTime(double time) {
    m_trigTime = time;
}

double Fei4TriggerLoop::getTrigTime() {
    return m_trigTime;
}

void Fei4TriggerLoop::setIsInner(bool itis) {
    isInner = itis;
}

bool Fei4TriggerLoop::getIsInner() {
    return isInner;
}

