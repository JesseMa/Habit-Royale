const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// MARK: - Pet Evolution System

/**
 * Check for pet evolution when level increases
 */
exports.checkPetEvolution = functions.firestore
    .document('users/{userId}/pets/{petId}')
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();
        
        // Check if level increased
        if (newData.level > oldData.level) {
            const newEvolution = getEvolutionForLevel(newData.level);
            
            if (newEvolution !== newData.evolution) {
                console.log(`Pet ${context.params.petId} evolving to ${newEvolution}`);
                
                // Update pet evolution
                await change.after.ref.update({
                    evolution: newEvolution,
                    // Boost stats on evolution
                    maxHealth: newData.maxHealth + 20,
                    health: Math.min(newData.health + 20, newData.maxHealth + 20),
                    attack: newData.attack + 5,
                    defense: newData.defense + 5
                });
                
                // Award evolution achievement
                await awardEvolutionAchievement(context.params.userId, newEvolution);
                
                // Send push notification
                await sendEvolutionNotification(context.params.userId, newData.name, newEvolution);
            }
        }
        
        return null;
    });

function getEvolutionForLevel(level) {
    if (level >= 25) return 5; // legendary
    if (level >= 15) return 4; // elite
    if (level >= 8) return 3;  // adult
    if (level >= 3) return 2;  // young
    if (level >= 1) return 1;  // baby
    return 0; // egg
}

// MARK: - Daily Pet Health Decay

/**
 * Daily health decay for all pets
 * Runs at 6 AM Berlin time
 */
exports.dailyPetHealthDecay = functions.pubsub
    .schedule('0 6 * * *')
    .timeZone('Europe/Berlin')
    .onRun(async (context) => {
        console.log('Starting daily pet health decay...');
        
        const batch = admin.firestore().batch();
        let processedCount = 0;
        
        // Get all users
        const usersSnapshot = await admin.firestore().collection('users').get();
        
        for (const userDoc of usersSnapshot.docs) {
            const petsSnapshot = await userDoc.ref.collection('pets').get();
            
            for (const petDoc of petsSnapshot.docs) {
                const pet = petDoc.data();
                const lastFed = pet.lastFed?.toDate() || new Date(0);
                const now = new Date();
                const daysSinceLastFed = Math.floor((now - lastFed) / (1000 * 60 * 60 * 24));
                
                if (daysSinceLastFed > 0) {
                    const healthDecay = Math.min(daysSinceLastFed * 10, pet.health);
                    const newHealth = Math.max(0, pet.health - healthDecay);
                    
                    batch.update(petDoc.ref, { 
                        health: newHealth,
                        lastHealthDecay: admin.firestore.FieldValue.serverTimestamp()
                    });
                    
                    processedCount++;
                    
                    // Send low health notification if needed
                    if (newHealth <= 20 && pet.health > 20) {
                        await sendLowHealthNotification(userDoc.id, pet.name);
                    }
                }
            }
        }
        
        await batch.commit();
        console.log(`Processed health decay for ${processedCount} pets`);
        
        return null;
    });

// MARK: - Leaderboard Management

/**
 * Update leaderboard when user data changes
 */
exports.updateLeaderboard = functions.firestore
    .document('users/{userId}')
    .onWrite(async (change, context) => {
        const userId = context.params.userId;
        
        // Handle user deletion
        if (!change.after.exists) {
            await admin.firestore()
                .collection('leaderboard')
                .doc(userId)
                .delete();
            return null;
        }
        
        const userData = change.after.data();
        const score = await calculateUserScore(userId, userData);
        
        // Update weekly leaderboard
        await admin.firestore()
            .collection('leaderboard')
            .doc(`weekly_${userId}`)
            .set({
                userId,
                username: userData.username,
                score,
                period: 'weekly',
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            }, { merge: true });
        
        return null;
    });

/**
 * Calculate user score for leaderboard
 */
async function calculateUserScore(userId, userData) {
    let score = 0;
    
    // Base score from user level and experience
    score += userData.level * 25;
    score += Math.floor(userData.experience / 10);
    
    // Get active pet score
    if (userData.activePetId) {
        try {
            const petDoc = await admin.firestore()
                .collection('users').doc(userId)
                .collection('pets').doc(userData.activePetId)
                .get();
            
            if (petDoc.exists) {
                const pet = petDoc.data();
                score += pet.level * 50;
                score += pet.evolution * 100;
            }
        } catch (error) {
            console.log('Error getting pet data for score calculation:', error);
        }
    }
    
    // Weekly habit completion score
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    
    try {
        const habitLogsSnapshot = await admin.firestore()
            .collection('users').doc(userId)
            .collection('habitLogs')
            .where('date', '>=', weekAgo)
            .get();
        
        score += habitLogsSnapshot.size * 10;
    } catch (error) {
        console.log('Error getting habit logs for score calculation:', error);
    }
    
    return score;
}

// MARK: - Battle System

/**
 * Process battle completion
 */
exports.processBattleCompletion = functions.firestore
    .document('battles/{battleId}')
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();
        
        // Check if battle just completed
        if (newData.status === 'COMPLETED' && oldData.status !== 'COMPLETED') {
            const battleId = context.params.battleId;
            const winnerId = newData.winner;
            const loserId = winnerId === newData.challengerId ? newData.opponentId : newData.challengerId;
            
            // Award XP
            await awardBattleXP(winnerId, 30); // Winner gets 30 XP
            await awardBattleXP(loserId, 10);  // Loser gets 10 XP
            
            // Update battle stats
            await updateBattleStats(winnerId, true);
            await updateBattleStats(loserId, false);
            
            // Send notifications
            await sendBattleResultNotification(winnerId, true, battleId);
            await sendBattleResultNotification(loserId, false, battleId);
        }
        
        return null;
    });

/**
 * Award XP to user and active pet
 */
async function awardBattleXP(userId, xpAmount) {
    const userRef = admin.firestore().collection('users').doc(userId);
    
    await admin.firestore().runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) return;
        
        const userData = userDoc.data();
        const newUserXP = userData.experience + xpAmount;
        const newUserLevel = Math.floor(newUserXP / 100) + 1;
        
        // Update user
        transaction.update(userRef, {
            experience: newUserXP,
            level: newUserLevel
        });
        
        // Update active pet if exists
        if (userData.activePetId) {
            const petRef = userRef.collection('pets').doc(userData.activePetId);
            const petDoc = await transaction.get(petRef);
            
            if (petDoc.exists) {
                const petData = petDoc.data();
                const newPetXP = petData.experience + xpAmount;
                const newPetLevel = Math.floor(newPetXP / 50) + 1;
                
                transaction.update(petRef, {
                    experience: newPetXP,
                    level: newPetLevel
                });
            }
        }
    });
}

// MARK: - Achievements System

/**
 * Check for streak achievements
 */
exports.checkStreakAchievements = functions.firestore
    .document('users/{userId}/streak/{streakId}')
    .onWrite(async (change, context) => {
        if (!change.after.exists) return null;
        
        const userId = context.params.userId;
        const streakData = change.after.data();
        const currentStreak = streakData.count || 0;
        
        const milestones = [3, 7, 30, 100];
        
        for (const milestone of milestones) {
            if (currentStreak === milestone) {
                await awardAchievement(userId, `streak_${milestone}`, {
                    title: `${milestone} Tage Streak!`,
                    description: `Du hast ${milestone} Tage in Folge deine Gewohnheiten verfolgt!`,
                    icon: '🔥',
                    xpReward: milestone * 5
                });
            }
        }
        
        return null;
    });

/**
 * Award achievement to user
 */
async function awardAchievement(userId, achievementId, achievementData) {
    const achievementRef = admin.firestore()
        .collection('users').doc(userId)
        .collection('achievements').doc(achievementId);
    
    // Check if already awarded
    const existingAchievement = await achievementRef.get();
    if (existingAchievement.exists) return;
    
    // Award achievement
    await achievementRef.set({
        ...achievementData,
        awardedAt: admin.firestore.FieldValue.serverTimestamp(),
        isNew: true
    });
    
    // Award XP if specified
    if (achievementData.xpReward) {
        await awardBattleXP(userId, achievementData.xpReward);
    }
    
    // Send notification
    await sendAchievementNotification(userId, achievementData);
}

// MARK: - Push Notifications

/**
 * Send low health notification
 */
async function sendLowHealthNotification(userId, petName) {
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    
    if (!userDoc.exists) return;
    
    const fcmToken = userDoc.data().fcmToken;
    if (!fcmToken) return;
    
    const message = {
        token: fcmToken,
        notification: {
            title: `${petName} braucht Aufmerksamkeit!`,
            body: 'Die Gesundheit deines Pets ist niedrig. Logge deine Gewohnheiten um es zu heilen!'
        },
        data: {
            type: 'LOW_HEALTH',
            petName: petName
        }
    };
    
    try {
        await admin.messaging().send(message);
    } catch (error) {
        console.log('Error sending low health notification:', error);
    }
}

/**
 * Send evolution notification
 */
async function sendEvolutionNotification(userId, petName, evolution) {
    const evolutionNames = ['Ei', 'Baby', 'Jung', 'Erwachsen', 'Elite', 'Legendär'];
    const evolutionName = evolutionNames[evolution] || 'Unbekannt';
    
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    
    if (!userDoc.exists) return;
    
    const fcmToken = userDoc.data().fcmToken;
    if (!fcmToken) return;
    
    const message = {
        token: fcmToken,
        notification: {
            title: `${petName} hat sich entwickelt! 🎉`,
            body: `Dein Pet ist jetzt ${evolutionName}!`
        },
        data: {
            type: 'EVOLUTION',
            petName: petName,
            evolution: evolution.toString()
        }
    };
    
    try {
        await admin.messaging().send(message);
    } catch (error) {
        console.log('Error sending evolution notification:', error);
    }
}

/**
 * Send achievement notification
 */
async function sendAchievementNotification(userId, achievementData) {
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    
    if (!userDoc.exists) return;
    
    const fcmToken = userDoc.data().fcmToken;
    if (!fcmToken) return;
    
    const message = {
        token: fcmToken,
        notification: {
            title: 'Neuer Erfolg freigeschaltet! 🌟',
            body: achievementData.title
        },
        data: {
            type: 'ACHIEVEMENT',
            achievementTitle: achievementData.title,
            achievementDescription: achievementData.description
        }
    };
    
    try {
        await admin.messaging().send(message);
    } catch (error) {
        console.log('Error sending achievement notification:', error);
    }
}

// MARK: - Data Cleanup

/**
 * Clean up expired battles
 */
exports.cleanupExpiredBattles = functions.pubsub
    .schedule('0 2 * * *') // 2 AM daily
    .timeZone('Europe/Berlin')
    .onRun(async (context) => {
        const now = new Date();
        const batch = admin.firestore().batch();
        
        const expiredBattlesSnapshot = await admin.firestore()
            .collection('battles')
            .where('expiresAt', '<', now)
            .where('status', 'in', ['PENDING', 'ACTIVE'])
            .get();
        
        expiredBattlesSnapshot.docs.forEach(doc => {
            batch.update(doc.ref, { status: 'EXPIRED' });
        });
        
        await batch.commit();
        console.log(`Expired ${expiredBattlesSnapshot.size} battles`);
        
        return null;
    });

/**
 * Update battle stats
 */
async function updateBattleStats(userId, won) {
    const statsRef = admin.firestore()
        .collection('users').doc(userId)
        .collection('battleStats').doc('summary');
    
    await statsRef.set({
        totalBattles: admin.firestore.FieldValue.increment(1),
        wins: won ? admin.firestore.FieldValue.increment(1) : admin.firestore.FieldValue.increment(0),
        losses: won ? admin.firestore.FieldValue.increment(0) : admin.firestore.FieldValue.increment(1),
        lastBattleAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
}

/**
 * Send battle result notification
 */
async function sendBattleResultNotification(userId, won, battleId) {
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    
    if (!userDoc.exists) return;
    
    const fcmToken = userDoc.data().fcmToken;
    if (!fcmToken) return;
    
    const message = {
        token: fcmToken,
        notification: {
            title: won ? 'Kampf gewonnen! 🏆' : 'Kampf verloren 😔',
            body: won ? 'Du hast 30 XP erhalten!' : 'Du hast 10 XP erhalten!'
        },
        data: {
            type: 'BATTLE_RESULT',
            won: won.toString(),
            battleId: battleId
        }
    };
    
    try {
        await admin.messaging().send(message);
    } catch (error) {
        console.log('Error sending battle result notification:', error);
    }
}

/**
 * Award evolution achievement
 */
async function awardEvolutionAchievement(userId, evolution) {
    const evolutionNames = ['Ei', 'Baby', 'Jung', 'Erwachsen', 'Elite', 'Legendär'];
    const evolutionName = evolutionNames[evolution] || 'Unbekannt';
    
    await awardAchievement(userId, `evolution_${evolution}`, {
        title: `${evolutionName} Evolution!`,
        description: `Dein Pet hat sich zu ${evolutionName} entwickelt!`,
        icon: evolution >= 4 ? '👑' : '⭐',
        xpReward: evolution * 10
    });
}