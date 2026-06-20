import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:harmfilter_flutter/models/quiz_question_model.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String language; // 'English' or 'Roman Urdu'
  final int points;
  final IconData icon;
  final Color color;
  final List<Question> questions;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.points,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

// ─── ENGLISH QUIZZES ────────────────────────────────────────────────────────

final List<Quiz> allQuizzes = [
  // ═════════════════════════════════════════════════════════════════════════
  // EN_1: HATE SPEECH BASICS (12 questions, 135 points possible)
  // ═════════════════════════════════════════════════════════════════════════
  Quiz(
    id: 'en_1',
    title: 'Hate Speech Basics',
    description:
        'Can you identify what counts as hate speech? Start here to find out.',
    language: 'English',
    points: 50,
    icon: LucideIcons.shield,
    color: Color(0xFF14B8A6),
    questions: [
      // Q1: MCQ
      MCQQuestion(
        id: 'en_1_q1',
        questionText: 'Which of the following is an example of hate speech?',
        explanation:
            'Blanket statements that paint an entire group as criminals are a textbook example of hate speech — they dehumanize people based on their origin.',
        options: [
          '"I disagree with your political views."',
          '"All people from that country are criminals."',
          '"I prefer different music than you."',
        ],
        correctAnswerIndex: 1,
      ),

      // Q2: TrueFalse
      TrueFalseQuestion(
        id: 'en_1_q2',
        questionText:
            'Dehumanization is one of the most dangerous forms of hate speech.',
        explanation:
            'True. Dehumanization — comparing groups to animals, diseases, or pests — can precede real-world violence and discrimination.',
        correctAnswer: true,
      ),

      // Q3: FillBlank
      FillBlankQuestion(
        id: 'en_1_q3',
        questionText: 'Microaggressions are subtle [blank] statements.',
        explanation:
            'Microaggressions are subtle, everyday slights that communicate hostile or negative messages to people from marginalized groups.',
        template: 'Microaggressions are subtle [blank] statements.',
        correctAnswers: ['harmful', 'offensive', 'discriminatory', 'insulting'],
        hints: 'Think: what is the nature of a microaggression?',
      ),

      // Q4: MCQ
      MCQQuestion(
        id: 'en_1_q4',
        questionText:
            'A person posts: "These people should not be allowed to live here." Is this hate speech?',
        explanation:
            'Calling for the exclusion or removal of a group of people based on identity is hate speech, regardless of how it is framed.',
        options: [
          'No, it\'s just an opinion about immigration.',
          'Yes, it targets a group and calls for their exclusion.',
          'Only if the person is famous.',
        ],
        correctAnswerIndex: 1,
      ),

      // Q5: TrueFalse
      TrueFalseQuestion(
        id: 'en_1_q5',
        questionText:
            'Laws against hate speech are the same in every country worldwide.',
        explanation:
            'False. Laws around hate speech differ significantly between countries. What matters universally is the real-world harm it causes.',
        correctAnswer: false,
      ),

      // Q6: MatchingQuestion
      MatchingQuestion(
        id: 'en_1_q6',
        questionText:
            'Match these coded phrases to what they actually mean:',
        explanation:
            'Coded hate speech uses vague language to target groups. Understanding these phrases helps you recognize hidden discrimination.',
        leftItems: [
          '"They are replacing us"',
          '"One of the good ones"',
          '"I\'m not racist, but..."',
        ],
        rightItems: [
          'Denial preface to justify prejudiced statement',
          'Conspiracy theory targeting ethnic/religious groups',
          'Backhanded compliment suggesting group inferiority',
        ],
        correctPairs: {0: 1, 1: 2, 2: 0},
      ),

      // Q7: ScenarioQuestion (15 pts)
      ScenarioQuestion(
        id: 'en_1_q7',
        scenario:
            'You see someone post hateful content online targeting a religious group. It already has 100+ shares.',
        questionText: 'What is the best first step?',
        explanation:
            'Reporting to the platform helps moderators take action. Engaging with hateful content often amplifies it further.',
        reasoning:
            'Professional moderation teams can take action faster and prevent harmful content from spreading.',
        options: [
          'Reply with an equally harsh comment.',
          'Ignore it; it will go away on its own.',
          'Report it to the platform and avoid engaging hostilely.',
          'Share it more to get others to report it.',
        ],
        correctAnswerIndex: 2,
      ),

      // Q8: MCQ
      MCQQuestion(
        id: 'en_1_q8',
        questionText:
            'Which phrase is a microaggression that questions someone\'s belonging?',
        explanation:
            '"Where are you REALLY from?" implies the person doesn\'t belong in the country they call home. It subtly questions their identity.',
        options: [
          '"Where are you really from?"',
          '"Nice to meet you!"',
          '"What is your favourite food?"',
        ],
        correctAnswerIndex: 0,
      ),

      // Q9: FillBlank
      FillBlankQuestion(
        id: 'en_1_q9',
        questionText:
            '"Where are you really from?" implies the person is not truly [blank] to this country.',
        explanation:
            'This question suggests the person is not truly "from" or "part of" this country, implying they don\'t belong there permanently.',
        template:
            '"Where are you really from?" implies the person is not truly [blank] to this country.',
        correctAnswers: ['belonging', 'native', 'from', 'part', 'accepted'],
        hints: 'What does the question suggest about the person\'s status?',
      ),

      // Q10: MultiSelectQuestion
      MultiSelectQuestion(
        id: 'en_1_q10',
        questionText: 'Select ALL that are examples of hate speech:',
        explanation:
            'All of these are forms of hate speech. Hate speech can take many forms — from direct slurs to stereotyping and dehumanization.',
        options: [
          'Direct slurs targeting a group',
          'Stereotyping a religious group as violent',
          'Calling for exclusion of a group',
          'Disagreeing with someone\'s opinions',
        ],
        correctAnswerIndices: [0, 1, 2],
      ),

      // Q11: TrueFalse
      TrueFalseQuestion(
        id: 'en_1_q11',
        questionText:
            'Anonymity online reduces the real harm caused by hate speech.',
        explanation:
            'False. Victims experience real psychological harm regardless of the speaker\'s anonymity. Fear, stress, and trauma are all genuine.',
        correctAnswer: false,
      ),

      // Q12: ScenarioQuestion (15 pts)
      ScenarioQuestion(
        id: 'en_1_q12',
        scenario:
            'Your close friend shares a hateful post online. They say they didn\'t mean to spread hate, they just thought it was funny.',
        questionText: 'What should you do?',
        explanation:
            'Staying silent normalizes the behaviour. A calm, private conversation is usually more effective than public shaming.',
        reasoning:
            'Direct, respectful communication can change minds while preserving relationships. Public shaming often triggers defensiveness.',
        options: [
          'Like it to keep the friendship intact.',
          'Ignore it and hope they delete it themselves.',
          'Calmly explain why it\'s harmful and ask them to remove it privately.',
          'Report them to the platform immediately.',
        ],
        correctAnswerIndex: 2,
      ),
    ],
  ),

  // ═════════════════════════════════════════════════════════════════════════
  // EN_2: SPOT THE HARM (13 questions, 145 points possible)
  // ═════════════════════════════════════════════════════════════════════════
  Quiz(
    id: 'en_2',
    title: 'Spot the Harm',
    description:
        'Go deeper — learn to spot coded language and subtle discrimination.',
    language: 'English',
    points: 100,
    icon: LucideIcons.eye,
    color: Color(0xFFF59E0B),
    questions: [
      // Q1: MCQ
      MCQQuestion(
        id: 'en_2_q1',
        questionText:
            'Someone says: "I\'m not racist, but…" and then makes a racist remark. What is this called?',
        explanation:
            'The "I\'m not racist, but..." preface is a common rhetorical move that attempts to grant permission for a prejudiced statement that follows.',
        options: [
          'An honest opinion.',
          'A denial preface — using "I\'m not racist" to justify a racist statement.',
          'A compliment gone wrong.',
        ],
        correctAnswerIndex: 1,
      ),

      // Q2: FillBlank
      FillBlankQuestion(
        id: 'en_2_q2',
        questionText: 'Dehumanization means describing a group of people as [blank] than human.',
        explanation:
            'Dehumanization involves describing groups as less than or inferior to human, often comparing them to animals or objects.',
        template: 'Dehumanization means describing a group of people as [blank] than human.',
        correctAnswers: ['less', 'worse', 'lower', 'inferior'],
        hints: 'Comparing people to animals or pests...',
      ),

      // Q3: MatchingQuestion
      MatchingQuestion(
        id: 'en_2_q3',
        questionText: 'Match harmful stereotypes to their harmful category:',
        explanation:
            'Understanding how stereotypes are categorized helps you recognize patterns of discrimination.',
        leftItems: [
          'All members of Group X are criminals',
          'Women are too emotional for leadership',
          'Group Y people are stealing jobs',
        ],
        rightItems: [
          'Threat-based stereotype',
          'Competence/ability stereotype',
          'Moral/character stereotype',
        ],
        correctPairs: {0: 2, 1: 1, 2: 0},
      ),

      // Q4: TrueFalse
      TrueFalseQuestion(
        id: 'en_2_q4',
        questionText: 'Humour is an exemption from content being harmful.',
        explanation:
            'False. Humour does not exempt content from being harmful. Stereotyping is still stereotyping, whether it\'s "a joke" or not.',
        correctAnswer: false,
      ),

      // Q5: MCQ
      MCQQuestion(
        id: 'en_2_q5',
        questionText: 'Which is an example of coded hate speech?',
        explanation:
            'Phrases like "those people are replacing us" are coded hate speech — they use vague language to spread conspiracy theories targeting ethnic or religious groups.',
        options: [
          '"I love pizza."',
          '"Those people are replacing us." (emphasizing specific ethnic group)',
          '"Traffic was bad today."',
        ],
        correctAnswerIndex: 1,
      ),

      // Q6: MultiSelectQuestion
      MultiSelectQuestion(
        id: 'en_2_q6',
        questionText: 'Select ALL of these that are microaggressions:',
        explanation:
            'Microaggressions are subtle, everyday slights that communicate hostile or negative messages.',
        options: [
          '"You\'re so articulate... for someone like you"',
          '"Where are you REALLY from?"',
          '"That\'s so gay" (using as negative)',
          '"Can I help you find something?" (in a store)',
        ],
        correctAnswerIndices: [0, 1, 2],
      ),

      // Q7: ScenarioQuestion (15 pts)
      ScenarioQuestion(
        id: 'en_2_q7',
        scenario:
            'An entire religious community is being targeted with coordinated hateful posts across social media. Multiple hate accounts are sharing similar content in a coordinated way.',
        questionText: 'What is the best community response?',
        explanation:
            'Coordinated positive responses — mass reporting and uplifting targeted communities — are the most effective defences against hate campaigns.',
        reasoning:
            'Collective action amplifies the signal for platform moderation and shows community solidarity.',
        options: [
          'Each person responds individually with angry counter-posts.',
          'Coordinate calm response: report together, amplify positive community content, support targets.',
          'Leave the platform entirely.',
          'Only ignore it and hope others report it.',
        ],
        correctAnswerIndex: 1,
      ),

      // Q8: FillBlank
      FillBlankQuestion(
        id: 'en_2_q8',
        questionText:
            'A stereotype is an overgeneralized [blank] about a particular group of people.',
        explanation:
            'Stereotypes are oversimplified beliefs or assumptions about groups that ignore individual variation and perpetuate bias.',
        template:
            'A stereotype is an overgeneralized [blank] about a particular group of people.',
        correctAnswers: ['belief', 'assumption', 'idea', 'notion', 'generalization'],
        hints: 'What do all members of a group supposedly share?',
      ),

      // Q9: MatchingQuestion
      MatchingQuestion(
        id: 'en_2_q9',
        questionText: 'Match the harmful phrase to its type:',
        explanation:
            'Different types of hate speech serve different harmful purposes. Recognizing the type helps you understand the intent.',
        leftItems: [
          '"Group X are pests/animals"',
          '"All members of Group X are criminals"',
          '"Group X member — you\'re one of the good ones"',
        ],
        rightItems: [
          'Stereotyping (overgeneralization)',
          'Dehumanization',
          'Backhanded compliment',
        ],
        correctPairs: {0: 1, 1: 0, 2: 2},
      ),

      // Q10: MCQ
      MCQQuestion(
        id: 'en_2_q10',
        questionText: 'Why is stereotyping harmful?',
        explanation:
            'Stereotyping creates false generalizations that lead to discrimination and deny individuals their unique identities.',
        options: [
          'It\'s just expressing general observations',
          'It dehumanizes groups and leads to real-world discrimination and bias',
          'It only affects online spaces',
        ],
        correctAnswerIndex: 1,
      ),

      // Q11: TrueFalse
      TrueFalseQuestion(
        id: 'en_2_q11',
        questionText: 'Online trolls are not causing real harm to communities.',
        explanation:
            'False. Victims of online hate experience genuine psychological harm including fear, anxiety, and PTSD.',
        correctAnswer: false,
      ),

      // Q12: ScenarioQuestion (15 pts)
      ScenarioQuestion(
        id: 'en_2_q12',
        scenario:
            'You see a meme that jokes about a religious group as being inherently violent. Many people are sharing it with laughing emojis.',
        questionText: 'What should you understand about this content?',
        explanation:
            'Humour does not exempt content from being harmful. This meme reinforces a dangerous stereotype that can lead to real discrimination.',
        reasoning:
            'Even "jokes" can spread harmful beliefs and contribute to systemic discrimination against groups.',
        options: [
          'It\'s just a joke, harmless fun.',
          'Only harmful if you take it seriously.',
          'It reinforces harmful stereotypes through humour and should be reported.',
          'It\'s educational about real religious differences.',
        ],
        correctAnswerIndex: 2,
      ),

      // Q13: MultiSelectQuestion
      MultiSelectQuestion(
        id: 'en_2_q13',
        questionText:
            'Select ALL warning signs of a hate campaign targeting a community:',
        explanation:
            'Recognizing coordinated hate campaigns helps you identify when organized harassment is happening.',
        options: [
          'Multiple similar hateful posts from different accounts',
          'Sudden spike in reported content about one group',
          'Organized targeting of specific individuals from that community',
          'Hashtags used to coordinate attacks',
        ],
        correctAnswerIndices: [0, 1, 2, 3],
      ),
    ],
  ),

  // ═════════════════════════════════════════════════════════════════════════
  // EN_3: COUNTER & RESPOND (15 questions, 170 points possible)
  // ═════════════════════════════════════════════════════════════════════════
  Quiz(
    id: 'en_3',
    title: 'Counter & Respond',
    description:
        'Master-level: learn how to safely counter hate speech and protect communities.',
    language: 'English',
    points: 200,
    icon: LucideIcons.messageSquare,
    color: Color(0xFFEF4444),
    questions: [
      // Q1: ScenarioQuestion (15 pts)
      ScenarioQuestion(
        id: 'en_3_q1',
        scenario:
            'A hateful post goes viral with thousands of shares. It contains misinformation about an ethnic group and is inciting real-world action.',
        questionText: 'What is your immediate strategy?',
        explanation:
            'Mass reporting combined with counter-narratives is most effective. Quick platform action prevents spread.',
        reasoning:
            'Platforms prioritize high-volume reports. Counter-narratives provide alternative information for people still forming opinions.',
        options: [
          'Engage directly with the poster to debate them',
          'Mass report + share counter-information from credible sources + coordinate community support',
          'Share your own angry response',
          'Wait for the platform to notice and remove it',
        ],
        correctAnswerIndex: 1,
      ),

      // Q2: MatchingQuestion
      MatchingQuestion(
        id: 'en_3_q2',
        questionText:
            'Match counter-speech strategies to their effectiveness level:',
        explanation:
            'Different strategies work in different contexts. Understanding effectiveness helps you choose the right approach.',
        leftItems: [
          'Presenting facts, humanizing stories, asking questions',
          'Matching anger with anger and aggression',
          'Sharing victim testimonies and community solidarity',
        ],
        rightItems: [
          'Low effectiveness - escalates conflict',
          'High effectiveness - changes minds and builds empathy',
          'Medium-high effectiveness - shows support, may shift observer opinions',
        ],
        correctPairs: {0: 1, 1: 0, 2: 2},
      ),

      // Q3: MCQ
      MCQQuestion(
        id: 'en_3_q3',
        questionText:
            'Which counter-speech strategy is generally considered most effective by research?',
        explanation:
            'Research shows counter-speech that humanizes victims and uses facts is more effective than aggression, which often escalates conflict.',
        options: [
          'Matching anger with anger.',
          'Presenting facts, humanizing stories, and asking questions.',
          'Blocking and never engaging.',
        ],
        correctAnswerIndex: 1,
      ),

      // Q4: FillBlank
      FillBlankQuestion(
        id: 'en_3_q4',
        questionText:
            'The "bystander effect" online occurs when everyone assumes someone [blank] will report or respond.',
        explanation:
            'The bystander effect is when people assume others will take action, leading everyone to inaction. Each person must feel responsible.',
        template:
            'The "bystander effect" online occurs when everyone assumes someone [blank] will report or respond.',
        correctAnswers: ['else', 'other', 'different', 'another'],
        hints: 'When many people see something, they assume...',
      ),

      // Q5: ScenarioQuestion (15 pts)
      ScenarioQuestion(
        id: 'en_3_q5',
        scenario:
            'A close friend shares hateful content online. They say they didn\'t mean to spread hate, they just thought it was funny.',
        questionText: 'What is the best approach?',
        explanation:
            'Staying silent normalizes the behaviour. A calm, private conversation is usually more effective than public shaming.',
        reasoning:
            'Private conversations create space for reflection without triggering defensiveness. They\'re more likely to listen and change.',
        options: [
          'Like it to keep the friendship.',
          'Publicly call them out on their post.',
          'Calmly explain why it\'s harmful and ask them to remove it privately.',
          'Unfriend them without explanation.',
        ],
        correctAnswerIndex: 2,
      ),

      // Q6: MultiSelectQuestion
      MultiSelectQuestion(
        id: 'en_3_q6',
        questionText:
            'Select ALL of these that are effective defences against hate campaigns:',
        explanation:
            'Effective responses are multi-layered and combine different tactics to minimize harm.',
        options: [
          'Mass reporting of coordinated accounts',
          'Amplifying positive community voices',
          'Supporting affected community members',
          'Sharing humanizing stories about targeted groups',
          'Engaging each hateful post individually with anger',
        ],
        correctAnswerIndices: [0, 1, 2, 3],
      ),

      // Q7: MatchingQuestion
      MatchingQuestion(
        id: 'en_3_q7',
        questionText: 'Match the situation to the most appropriate response:',
        explanation:
            'Different contexts require different responses. Flexibility in approach increases effectiveness.',
        leftItems: [
          'One person makes hateful comment',
          'Coordinated hate campaign',
          'Friend shares hateful content "as a joke"',
        ],
        rightItems: [
          'Private conversation with friend',
          'Community mass reporting + counter-narratives',
          'Respectful counter-speech with facts',
        ],
        correctPairs: {0: 2, 1: 1, 2: 0},
      ),

      // Q8: TrueFalse
      TrueFalseQuestion(
        id: 'en_3_q8',
        questionText:
            'Public shaming is more effective than private conversation for changing someone\'s mind.',
        explanation:
            'False. Public shaming usually triggers defensiveness and entrenches positions. Private conversation is usually more effective.',
        correctAnswer: false,
      ),

      // Q9: MCQ
      MCQQuestion(
        id: 'en_3_q9',
        questionText: 'Why is it important to take a screenshot of hate speech before reporting?',
        explanation:
            'The poster can delete content before the platform acts. Screenshots provide proof for your report.',
        options: [
          'To show your friends how bad the content is',
          'Platforms require screenshots to take action',
          'In case the content is removed, you have evidence for your report',
        ],
        correctAnswerIndex: 2,
      ),

      // Q10: FillBlank
      FillBlankQuestion(
        id: 'en_3_q10',
        questionText:
            'A coordinated community response includes mass [blank]], amplifying positive content, and supporting affected groups.',
        explanation:
            'Coordinated responses combine mass reporting, counter-narratives, and community support for maximum effect.',
        template:
            'A coordinated community response includes mass [blank], amplifying positive content, and supporting affected groups.',
        correctAnswers: ['reporting', 'reports', 'report'],
        hints: 'When many people act together toward platforms...',
      ),

      // Q11: ScenarioQuestion (15 pts)
      ScenarioQuestion(
        id: 'en_3_q11',
        scenario:
            'A vulnerable community (religious minority) is being targeted with a coordinated hate campaign. Hundreds of posts mock and threaten them.',
        questionText: 'What is the community\'s best strategy?',
        explanation:
            'Collective action combining reporting, counter-narratives, and community support is most effective and provides psychological protection.',
        reasoning:
            'Solidarity strengthens resilience. Mass reporting amplifies platform action. Counter-narratives reach observers and prevent spread.',
        options: [
          'Each person responds with angry counter-attacks',
          'Ignore it and don\'t amplify by engaging',
          'Coordinate mass reports, amplify positive community voices, and support each other publicly',
          'Report to law enforcement only',
        ],
        correctAnswerIndex: 2,
      ),

      // Q12: MultiSelectQuestion
      MultiSelectQuestion(
        id: 'en_3_q12',
        questionText:
            'Select ALL safety steps when doing counter-speech online:',
        explanation:
            'Your safety matters. Taking precautions protects your wellbeing while fighting hate.',
        options: [
          'Engage from a secure account with privacy settings enabled',
          'Never reveal personal information',
          'Have support people you can talk to about the experience',
          'Take breaks if it becomes emotionally draining',
          'Engage 1-on-1 with every person spreading hate',
        ],
        correctAnswerIndices: [0, 1, 2, 3],
      ),

      // Q13: MatchingQuestion
      MatchingQuestion(
        id: 'en_3_q13',
        questionText: 'Match warning signs to types of online radicalization:',
        explanation:
            'Understanding radicalization patterns helps you recognize when someone needs intervention.',
        leftItems: [
          'Sudden isolation from old friends, new echo chambers',
          'Increasing use of dehumanizing language',
          'Talking about "us vs them" constantly',
        ],
        rightItems: [
          'Us-vs-them worldview development',
          'Community isolation and indoctrination',
          'Dehumanization of outgroups',
        ],
        correctPairs: {0: 1, 1: 2, 2: 0},
      ),

      // Q14: ScenarioQuestion (15 pts)
      ScenarioQuestion(
        id: 'en_3_q14',
        scenario:
            'You\'re moderating a community forum. Someone posts content that is offensive but not violating platform rules. Others are reporting it heavily.',
        questionText:
            'How do you balance free speech principles with protecting the community?',
        explanation:
            'Platforms must consider harm and community safety, not just rule violations. Transparency about moderation decisions builds trust.',
        reasoning:
            'Protected speech and preventing harm are both important. Context, pattern, and impact matter in decisions.',
        options: [
          'Remove everything reported regardless of rules',
          'Never remove anything unless it violates explicit rules',
          'Analyze context and impact; remove if it causes disproportionate harm; explain decision transparently',
          'Let the poster decide if they remove it',
        ],
        correctAnswerIndex: 2,
      ),

      // Q15: MCQ
      MCQQuestion(
        id: 'en_3_q15',
        questionText:
            'How do we balance protecting free speech with preventing harm from hate speech?',
        explanation:
            'The most thoughtful approach considers both the value of expression and the real harm hate speech causes. Context and consequences matter.',
        options: [
          'Free speech always wins; never moderate hate speech',
          'All potentially offensive speech should be removed',
          'Consider impact on targeted groups, patterns of harm, and whether speech incites violence; make context-aware decisions',
        ],
        correctAnswerIndex: 2,
      ),
    ],
  ),

  // ═════════════════════════════════════════════════════════════════════════
  // UR_1: HATE SPEECH BASICS (Roman Urdu)
  // ═════════════════════════════════════════════════════════════════════════
  Quiz(
    id: 'ur_1',
    title: 'Naphrat Se Bhara Bayan - Bunyadi',
    description:
        'Kya aap shناخت kar sakte hain ke kaunsa bayan naphrat se bhara hua hai?',
    language: 'Roman Urdu',
    points: 50,
    icon: LucideIcons.shield,
    color: Color(0xFF14B8A6),
    questions: [
      MCQQuestion(
        id: 'ur_1_q1',
        questionText: 'Naphrat se bhara hua bayan kaun sa hai?',
        explanation:
            'Puri qaum ke liye khatre naak baatain kehna naphrat se bhara hua bayan hai jo insaniyat ko khatam karta hai.',
        options: [
          '"Mujhe aapke siyasi vichaar pasand nahi."',
          '"Us mulk ke sab log surkaar hain."',
          '"Mujhe aapka sangeet pasand nahi."',
        ],
        correctAnswerIndex: 1,
      ),
      TrueFalseQuestion(
        id: 'ur_1_q2',
        questionText:
            'Insaniyat ko khatam karna naphrat se bhare bayan ka sabse khatar naak roop hai.',
        explanation:
            'Bilkul sahi. Logon ko jawanwar, beemaari, ya keeda samajhna buhat khatarnak hai aur asli dunyawi tashadud ka shuruaat hai.',
        correctAnswer: true,
      ),
      FillBlankQuestion(
        id: 'ur_1_q3',
        questionText: 'Chhoti naphrat bhari baatain [blank] hoti hain.',
        explanation:
            'Chhoti naphrat bhari baatain roz merrah ki chhoti baatain hoti hain jo Kam log ko bura mahsoos karti hain.',
        template: 'Chhoti naphrat bhari baatain [blank] hoti hain.',
        correctAnswers: ['takleef deh', 'burai', 'namanzoor', 'ghaleez'],
        hints: 'Socho: chhoti naphrat bhari baatain kaunsa mahsool karti hain?',
      ),
      MCQQuestion(
        id: 'ur_1_q4',
        questionText:
            'Ek shakhs likhta hai: "Yeh log yahan nahi rehna chahiye." Kya ye naphrat se bhara hua bayan hai?',
        explanation:
            'Kisi qaum ko nikaalne ya dushmani karane wali baatain naphrat se bhara bayan hain.',
        options: [
          'Nahi, bas muhajarat ke baare mein ek ray hai.',
          'Haan, ye ek qaum ko nishana banata hai aur iska nikalna chahti hai.',
          'Sirf agar baat karne wala mashhoor ho.',
        ],
        correctAnswerIndex: 1,
      ),
      TrueFalseQuestion(
        id: 'ur_1_q5',
        questionText:
            'Naphrat se bhare bayan ke khilaf kanoon har mulk mein ek jaisa hai.',
        explanation:
            'Galat. Har mulk ke kanoon alag hain, lekin naphrat se bhare bayan se hone wali hani har jagah ek jaisa hai.',
        correctAnswer: false,
      ),
      MatchingQuestion(
        id: 'ur_1_q6',
        questionText: 'Ramooz ko sahi muani se milao:',
        explanation:
            'Chupe hue naphrat bhari baaton ko samjhna zaroori hai takay unhe pehchan saken.',
        leftItems: [
          '"Un logon ke baare mein acha nahi kehna"',
          '"Woh log hamari tarah nahin hain"',
          '"Unhain yahan se nikalna chahiye"',
        ],
        rightItems: [
          'Nikaalnay ki baat',
          'Farq banana',
          'Burai kehna',
        ],
        correctPairs: {0: 2, 1: 1, 2: 0},
      ),
      ScenarioQuestion(
        id: 'ur_1_q7',
        scenario:
            'Aapka ek dost naphrat se bhara hua mazak suna raha hai aur logo ko hasaya ja raha hai.',
        questionText: 'Aap kya karengy?',
        explanation:
            'Chaup rehna takleef ko badhata hai. Apna naqta-e-nazar share karna aur madad ki peshkash zaroori hai.',
        reasoning:
            'Dost ko samjhana aur madad dena pehla qadam hai. Chaup rahna nuksan ko badhata hai.',
        options: [
          'Chaup raho aur kisi se na kaho',
          'Dost se kaho ke ye mazak thik nahi hai aur unhain samjhao',
          'Public mein isay rokne ki koshish karo',
          'Sirf online report karo',
        ],
        correctAnswerIndex: 1,
      ),
      FillBlankQuestion(
        id: 'ur_1_q8',
        questionText: 'Naphrat se bhare bayan ko roknay ka pehla qadam [blank] hai.',
        explanation:
            'Pehla qadam sharah mein baat karna aur samjhana hai. Iska matlab ye nahi ke log sab badal jayein, lekin koshish karna zaroori hai.',
        template: 'Naphrat se bhare bayan ko roknay ka pehla qadam [blank] hai.',
        correctAnswers: ['baat karna', 'samjhana', 'kehna', 'aawaaz uthana'],
        hints: 'Kya kadam roknay se pehle aata hai?',
      ),
      MCQQuestion(
        id: 'ur_1_q9',
        questionText:
            'Jab aap naphrat se bhara bayan dekho, aapka pehla kaam kya hona chahiye?',
        explanation:
            'Pehle apne aap ko surakshit rakho, phir madad manga, aur phir report karo.',
        options: [
          'Turant bagair soche samjhe jabab do',
          'Apne aap ko surakshit rakho aur madad manga',
          'Bina ruke hue report karo',
        ],
        correctAnswerIndex: 1,
      ),
      MultiSelectQuestion(
        id: 'ur_1_q10',
        questionText: 'Naphrat se bhare bayan SAATH kaunsa karwai zaroori hai?',
        explanation:
            'Kuch nahi - har harkat ke saath saath aapki surakshit rehna sabse zaroori hai.',
        options: [
          'Report kro',
          'Counter speech likho',
          'Apne aap ko sanbhalo',
          'Madad manga',
          'Akela taqaam karo',
        ],
        correctAnswerIndices: [0, 1, 2, 3],
      ),
      TrueFalseQuestion(
        id: 'ur_1_q11',
        questionText:
            'Anonymity (naam na batana) se nuksan kam ho jata hai online.',
        explanation:
            'Galat. Naam na batana nuksan ko badhata hai kyun ke log jyada be-raham baatain kehte hain.',
        correctAnswer: false,
      ),
      ScenarioQuestion(
        id: 'ur_1_q12',
        scenario:
            'Aapka dostana naphrat se bhara hua content share karata hai jo tumhare samaj ko naamanjar hai.',
        questionText: 'Aap kya karengy?',
        explanation:
            'Dost se detail se baat karo, samjhao ke ye kyun galat hai, aur madad peshkash karo.',
        reasoning:
            'Dosti bachchane ka matlab ye nahi ke galat baatain sunate raho. Sacha dost woh hai jo aapko sudharta hai.',
        options: [
          'Dost ko unfriend kar do',
          'Khud bhi share kro iska jawab dene ke liye',
          'Dost se baat karo aur unhe samjhao',
          'Police ko report kro',
        ],
        correctAnswerIndex: 2,
      ),
    ],
  ),

  // ═════════════════════════════════════════════════════════════════════════
  // UR_2: SPOT THE HARM (Roman Urdu)
  // ═════════════════════════════════════════════════════════════════════════
  Quiz(
    id: 'ur_2',
    title: 'Naqsan ko Pehchano',
    description:
        'Chupe hue aur zulli naphrat se bhare baatain pehchanay ki practice karo.',
    language: 'Roman Urdu',
    points: 100,
    icon: LucideIcons.eye,
    color: Color(0xFFE67E22),
    questions: [
      MCQQuestion(
        id: 'ur_2_q1',
        questionText:
            'Agar kisi shakhs ne kaha "Woh log hamari tarah nahi hain" to ye kaun sa tareeqa hai?',
        explanation: 'Ye ramooz lamahi tafreech (othering) hai jahan logo ko alag dikhaya ja raha hai.',
        options: [
          'Ek sach ki baat',
          'Ramooz lamahi tafreech',
          'Hoshiyari',
        ],
        correctAnswerIndex: 1,
      ),
      FillBlankQuestion(
        id: 'ur_2_q2',
        questionText: 'Insaniyat ko khatam karna = logon ko [blank] samjhna.',
        explanation:
            'Insaniyat ko khatam karna logon ko anjaan, bekadar, ya adam-shemar samajhna hai.',
        template: 'Insaniyat ko khatam karna = logon ko [blank] samjhna.',
        correctAnswers: ['kamtar', 'bekadar', 'adam-shemar', 'janwar'],
        hints: 'Insaniyat ko khatam karta kaun sa lafz?',
      ),
      MatchingQuestion(
        id: 'ur_2_q3',
        questionText: 'Tafreech qasmein aur unke nimune milao:',
        explanation:
            'Tafreech ke alag tareeqay hain. Inhe samjhna hissa-ye-kaari mein madad deta hai.',
        leftItems: [
          'Puri qaum ko khatre naak kehna',
          'Log ko janwar ya beemaari kehna',
          'Alag nikalne ki koshish karna',
        ],
        rightItems: [
          'Insaniyat ko khatam karna',
          'Shahri aur raaj hamla',
          'Negative stereotype',
        ],
        correctPairs: {0: 2, 1: 0, 2: 1},
      ),
      TrueFalseQuestion(
        id: 'ur_2_q4',
        questionText: 'Hasrat nukashan ko kam ker deti hai.',
        explanation:
            'Galat. Hasrat often tarkee karte waqt nuksaan ko badhati hai kyun ke logo ko lagta hai ke themselve funny han.',
        correctAnswer: false,
      ),
      MCQQuestion(
        id: 'ur_2_q5',
        questionText: 'Ramooz naklaq naphrat se bhara bayan kaun sa hai?',
        explanation:
            'Ramooz tazeeb = chhupe hue tareeqay se kisi qaum ko le-varkhatah samajhna.',
        options: [
          'Seedhi tarah shikayat karna',
          'Chhepe tareeqay se naqsan pahunchana aur qaum ko le-varkhatah samajhna',
          'Sirf ek bakhabar ko report karna',
        ],
        correctAnswerIndex: 1,
      ),
      MultiSelectQuestion(
        id: 'ur_2_q6',
        questionText: 'Naphrat se bhare baatain SAATH kaunsi sab hoti hain?',
        explanation:
            'Naphrat se bhare baatain alag alag tareeqay se ati hain aur har ek nuksan krti hai.',
        options: [
          'Seedhi tarah buri baatain kehna',
          'Ramooz aur chhepe tareeqay',
          'Jhooth se sach banana',
          'Logon ko kaum se alag samajhna',
          'Hasrat se nuksan pahunchana',
        ],
        correctAnswerIndices: [0, 1, 2, 3],
      ),
      ScenarioQuestion(
        id: 'ur_2_q7',
        scenario:
            'Aapke office mein ek colleague har roz ek khaas qaum ke baare mein negative baatain kehta hai. Kisi ne kuch nahi kaha.',
        questionText: 'Aap kya karengy?',
        explanation:
            'Chaup rehna nuksaan ko badhata hai. Apne HR ko report karo aur saath-hi apne colleague se direct baat kro agar surakshit mahesooss karo.',
        reasoning:
            'Workplace mein discrimination tay karna zaroori hai. Surakshit rehte hue aavaaz uthao.',
        options: [
          'Chaup raho kyun ke ye HR ka masla hai',
          'HR aur safe dost ko batao, phir colleague se baat kro',
          'Public mein colleague ko rooko',
          'Sirf colleague se poocho',
        ],
        correctAnswerIndex: 1,
      ),
      FillBlankQuestion(
        id: 'ur_2_q8',
        questionText: 'Stereotype = [blank] ke upar generalize karna.',
        explanation:
            'Stereotype ek aadmi par sari qaum ki khasiyatain lagana hai.',
        template: 'Stereotype = [blank] ke upar generalize karna.',
        correctAnswers: ['ek insan', 'ek shakhs', 'individual', 'personal'],
        hints: 'Stereotype ki bunya kya hai?',
      ),
      MatchingQuestion(
        id: 'ur_2_q9',
        questionText: 'Baatain aur unka naam milao:',
        explanation:
            'Har naphrat se bhara tareeqa ek khaas naam se pehchhana jata hai.',
        leftItems: [
          '"Un log neechay hain aur hamare se alag."',
          '"Woh sab surkaar hain."',
          '"Ye log hamara maal lutte hain."',
        ],
        rightItems: [
          'Stereotype',
          'Dehumanization (insaniyat se bari)',
          'Scapegoating (qasur lagana)',
        ],
        correctPairs: {0: 1, 1: 0, 2: 2},
      ),
      MCQQuestion(
        id: 'ur_2_q10',
        questionText: 'Stereotype nuksan kyun pahunchati hai?',
        explanation:
            'Stereotype real soch-samajh ko rok deti hai aur logon ke khilaaf bias banati hai.',
        options: [
          'Wo sirf uninteresting hain',
          'Wo real understanding ko rok deti hain aur discrimination create karti hain',
          'Wo sirf mazak hain',
        ],
        correctAnswerIndex: 1,
      ),
      TrueFalseQuestion(
        id: 'ur_2_q11',
        questionText:
            'Trolls (online ghare wale) se koi asli nuksan nahi hota kyun ke woh sirf online hain.',
        explanation:
            'Galat. Online harassment se asli dunyawi trauma, anxiety, aur kati kabhi physical attack tak ho sakta hai.',
        correctAnswer: false,
      ),
      ScenarioQuestion(
        id: 'ur_2_q12',
        scenario:
            'Social media par naphrat se bhara meme viral ho raha hai jo ek khaas qaum ke liye bura hai.',
        questionText: 'Aapka best action kaun sa hai?',
        explanation:
            'Report karo, counter-speech likho, support do affected logo ko, aur meme ko aage share mat karo.',
        reasoning:
            'Reporting + counter-content + support = sabse effective strategy.',
        options: [
          'Ignore kro kyun ke viral ho raha hai',
          'Report kro, counter speech likho, affected logon ko support do',
          'Aur jyada share kro awareness ke liye',
          'Sirf reporting sufficient hai',
        ],
        correctAnswerIndex: 1,
      ),
      MultiSelectQuestion(
        id: 'ur_2_q13',
        questionText: 'Naphrat se bhare campaign ke alamat kaun se hain?',
        explanation:
            'Campaign recognize karna zaroori hai takay turant action le saken.',
        options: [
          'Ek hi message bar bar share ho raha hai',
          'Ek hi qaum/group ko target kiya ja raha hai',
          'Logon ko bharti kiya ja raha hai',
          'Jhooth aur data manipulation',
          'Natural aur organic spread',
        ],
        correctAnswerIndices: [0, 1, 2, 3],
      ),
    ],
  ),

  // ═════════════════════════════════════════════════════════════════════════
  // UR_3: COUNTER & RESPOND (Roman Urdu)
  // ═════════════════════════════════════════════════════════════════════════
  Quiz(
    id: 'ur_3',
    title: 'Jawaab Do aur Counter Karo',
    description:
        'Naphrat se bhare baatain ka jawaab dene aur qabil-e-qubool counter karte seekhain.',
    language: 'Roman Urdu',
    points: 200,
    icon: LucideIcons.zap,
    color: Colors.purple,
    questions: [
      ScenarioQuestion(
        id: 'ur_3_q1',
        scenario:
            'Naphrat se bhara ek viral post turant-turant spread ho raha hai jo ek community ko attack kar raha hai.',
        questionText: 'Sabse behtar strategy kaun si hai?',
        explanation:
            'Collective action = reporting + counter-narratives + community support. Ye sabse powerful hai.',
        reasoning:
            'Akayla koshish kam effective hai. Samoohi koshish zyada takalif karti hai aur plateform action badhati hai.',
        options: [
          'Sirf report kro',
          'Sirf counter speech likho',
          'Coordinate: report + counter-narrative + community support',
          'Ignore kro kyun ke viral hai',
        ],
        correctAnswerIndex: 2,
      ),
      MatchingQuestion(
        id: 'ur_3_q2',
        questionText: 'Counter strategy ko effectiveness se milao:',
        explanation:
            'Kuch strategies zyada effective hain dusron se. Context matter karta hai.',
        leftItems: [
          'Direct argument samne wale se',
          'Community ko inspire karte hue positivity share karna',
          'Naphrat ko ignore karna aur na share krana',
        ],
        rightItems: [
          'Bahut kam effective - jhagra badhta hai',
          'Sabse effective - third-party observers ko reach karti hai',
          'Moderate - spread kam hota hai',
        ],
        correctPairs: {0: 0, 1: 1, 2: 2},
      ),
      MCQQuestion(
        id: 'ur_3_q3',
        questionText: 'Counter speech mein sabse behtar approach kaun si hai?',
        explanation:
            'Sabkhabar, educated, aur compassionate counter-speech sabse effective rah hai kyun ke ye observers ko move karti hai.',
        options: [
          'Emotional aur gussa se bhari counter attack',
          'Sabkhabar, educated, aur compassionate response',
          'Hamesha argument karo',
        ],
        correctAnswerIndex: 1,
      ),
      FillBlankQuestion(
        id: 'ur_3_q4',
        questionText:
            'Bystander effect = assuming [blank] else action le rahay hain.',
        explanation:
            'Bystander effect = jab bhid ho to log sochte hain koi aur handle kar dega.',
        template:
            'Bystander effect = assuming [blank] else action le rahay hain.',
        correctAnswers: [
          'koi aur',
          'someone else',
          'dusra shakhs',
          'baaki log'
        ],
        hints: 'Jab bhid mein nuksaan ho rahi ho to log kya sochte hain?',
      ),
      ScenarioQuestion(
        id: 'ur_3_q5',
        scenario:
            'Aapka ek close dost naphrat se bhara content share karta hai. Aap unse bahut pyaar karte ho.',
        questionText: 'Sabse behtar action kaun sa hai?',
        explanation:
            'Private conversation effective rah rehe hain. Direct, honest aur compassionate approach best hai dost ke liye.',
        reasoning:
            'Public shaming counter-productive hai. Private discussion trust rakhti hai aur growth ke liye space deti hai.',
        options: [
          'Public mein unhe shame kro',
          'Private baat kro, direct ho aur unhe sunnay do',
          'Unhe unfriend kar do',
          'Sirf report kro aur kuch mat kaho',
        ],
        correctAnswerIndex: 1,
      ),
      MultiSelectQuestion(
        id: 'ur_3_q6',
        questionText: 'Counter speech karte waqt safest defenses kaun si hain?',
        explanation:
            'Apne aap ko surakshit rakhte hue counter-speech karna zaroori hai.',
        options: [
          'Secure account aur privacy settings',
          'Personal info share mat karo',
          'Support group rakhna',
          'Exhaustion aur burnout se bachna',
          'Har ek se 1-on-1 jhagra kro',
        ],
        correctAnswerIndices: [0, 1, 2, 3],
      ),
      MatchingQuestion(
        id: 'ur_3_q7',
        questionText: 'Situation aur best response milao:',
        explanation:
            'Context-aware response sabse effective rah sakte hain.',
        leftItems: [
          'Close relation naphrat spread kar rahe hain',
          'Stranger ka naphrat viral ho raha hai',
          'Office colleague ne bias dikhayi',
        ],
        rightItems: [
          'HR aur formal complaint',
          'Community mobilization aur counter-narrative',
          'Private aur compassionate conversation',
        ],
        correctPairs: {0: 2, 1: 1, 2: 0},
      ),
      TrueFalseQuestion(
        id: 'ur_3_q8',
        questionText:
            'Public shaming > private conversation when countering hate speech.',
        explanation:
            'Galat. Private conversation zyada effective rah sakte hain aur long-term change create karte hain. Public shaming defensive bana deta hai.',
        correctAnswer: false,
      ),
      MCQQuestion(
        id: 'ur_3_q9',
        questionText:
            'Screenshot le kar report karte waqt sabse zaroori kya hai?',
        explanation:
            'Documentation important hai taakay platform ko prove kar sako aur investigation possible ho sake.',
        options: [
          'Zyada jaldi report kro',
          'Screenshot le kar context document karo',
          'Sirf screenshot theek hai',
        ],
        correctAnswerIndex: 1,
      ),
      FillBlankQuestion(
        id: 'ur_3_q10',
        questionText:
            'Coordinated response = mass [blank] + counter-narrative content.',
        explanation:
            'Coordinated response organized reporting + positive messaging ko combine karta hai.',
        template:
            'Coordinated response = mass [blank] + counter-narrative content.',
        correctAnswers: ['reporting', 'raporting', 'complaints', 'shikayatain'],
        hints: 'Coordinated response mein pehla step kaun sa hai?',
      ),
      ScenarioQuestion(
        id: 'ur_3_q11',
        scenario:
            'Ek khaas vulnerable community online attack mein hai. Aap unhe kaise support kar sakte ho?',
        questionText: 'Sabse behtar approach kaun si hai?',
        explanation:
            'Direct support, amplify their voices, coordinate with allies, report hate, prevent spread.',
        reasoning:
            'Vulnerable logon ko spotlight immediately chahiye. Amplification + solidarity + organized action = best response.',
        options: [
          'Unhe tell karo ke ignore karo',
          'Direct support + amplify voices + coordinate organized response + report',
          'Sirf sympathize kro',
          'Unhe Twitter pe khud defend karane de',
        ],
        correctAnswerIndex: 1,
      ),
      MultiSelectQuestion(
        id: 'ur_3_q12',
        questionText:
            'Counter speech karte waqt SATH kaun si precautions zaroori hain?',
        explanation:
            'Safety first. Ye precautions burnout aur harm se baachte hain.',
        options: [
          'Secure account se engage karo',
          'Personal info kabhi share mat karo',
          'Support system rakhna (friends, groups)',
          'Breaks lo agar emotionally draining lag rahe ho',
          'Har khilaaf opinion ko counter kro',
        ],
        correctAnswerIndices: [0, 1, 2, 3],
      ),
      MatchingQuestion(
        id: 'ur_3_q13',
        questionText: 'Radicalization ke alamat aur types milao:',
        explanation:
            'Radicalization recognize karna early intervention possible banata hai.',
        leftItems: [
          'Purane dosto se alag ho jana, naye echo chambers join karna',
          'Dehumanizing language barh jayegi',
          'Hamesha "us vs them" mentality',
        ],
        rightItems: [
          '"Us vs them" worldview',
          'Isolation aur indoctrination',
          'Dehumanization',
        ],
        correctPairs: {0: 1, 1: 2, 2: 0},
      ),
      ScenarioQuestion(
        id: 'ur_3_q14',
        scenario:
            'Aap ek community forum moderate kar rahe ho. Koi content offensive hai lekin technically rule break nahi kar raha.',
        questionText: 'Aap kya karengy?',
        explanation:
            'Harm consider karo, context dekho, impact samjho. Transparent decision aur explanation zaroori hai.',
        reasoning:
            'Rules sirf rules hain. Real responsibility community safety aur harm prevention mein hai.',
        options: [
          'Sab reported content remove kro',
          'Sirf rule-breaking remove kro, baki sab allow kro',
          'Context analyze karo, harm dekho, transparent decision do aur explain karo',
          'Poster ko khud decide karane do',
        ],
        correctAnswerIndex: 2,
      ),
      MCQQuestion(
        id: 'ur_3_q15',
        questionText:
            'Free speech aur hate speech se harm prevention mein balance kaisy banate ho?',
        explanation:
            'Thoughtful approach: consider impact, patterns, context, consequences. Both matter.',
        options: [
          'Free speech hamesha jaye, hate speech se koi tension nahi',
          'Sab potentially offensive speech remove kro',
          'Impact + patterns + context-aware decisions - ye balanced approach hai',
        ],
        correctAnswerIndex: 2,
      ),
    ],
  ),
];
