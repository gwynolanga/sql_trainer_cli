# frozen_string_literal: true

# db/learn_hub/seeds.rb
module LearnHubSeeds
  module_function

  def run
    puts("Starting idempotent seed process...")

    ActiveRecord::Base.transaction do
      roles = create_roles
      instructors = create_instructors(roles[:instructor])
      students = create_students(roles[:student])
      create_admin(roles[:admin])

      categories = create_categories
      courses = create_courses(categories, instructors)

      create_modules_and_lessons(courses)
      create_enrollments(courses, students)
      create_payments
      create_lesson_completions
      create_reviews
      create_certificates
      create_discussions
      create_submissions
      create_quiz_attempts

      print_summary

      puts("SEED COMPLETED SUCCESSFULLY!")
    end
  rescue StandardError => e
    puts("Seeding failed: #{e.class} - #{e.message}")
    raise
  end

  # Roles
  def create_roles
    puts("Creating roles...")
    roles = {}

    roles[:student] = LearnHub::Role.find_or_create_by!(name: 'student') do |r|
      r.description = 'Regular student who can enroll in courses'
    end

    roles[:instructor] = LearnHub::Role.find_or_create_by!(name: 'instructor') do |r|
      r.description = 'Can create and manage courses'
    end

    roles[:admin] = LearnHub::Role.find_or_create_by!(name: 'admin') do |r|
      r.description = 'System administrator with full access'
    end

    puts("Roles: #{LearnHub::Role.count}")
    roles
  end

  # Instructors
  def create_instructors(role)
    puts("Creating instructors...")

    instructor_names = [
      %w[Sarah Johnson sarah.johnson@learnhub.com],
      %w[Michael Chen michael.chen@learnhub.com],
      %w[Emily Rodriguez emily.rodriguez@learnhub.com],
      %w[David Kim david.kim@learnhub.com],
      %w[Anna Kowalski anna.kowalski@learnhub.com],
      %w[James Patel james.patel@learnhub.com],
      %w[Maria Santos maria.santos@learnhub.com],
      ["Robert", "O'Brien", 'robert.obrien@learnhub.com'],
      %w[Lisa Nguyen lisa.nguyen@learnhub.com],
      %w[Thomas Schmidt thomas.schmidt@learnhub.com],
      %w[Jennifer Anderson jennifer.anderson@learnhub.com],
      %w[Ahmed Hassan ahmed.hassan@learnhub.com],
      %w[Catherine Dubois catherine.dubois@learnhub.com],
      %w[Kevin Tanaka kevin.tanaka@learnhub.com],
      %w[Elena Ivanova elena.ivanova@learnhub.com]
    ]

    bios = [
      "Passionate educator with 10+ years of experience in software development and teaching.",
      "Former senior engineer at Google, now dedicated to making tech education accessible.",
      "PhD in Computer Science, specializing in machine learning and artificial intelligence.",
      "Full-stack developer turned instructor, helping thousands launch their tech careers.",
      "Award-winning teacher with a knack for explaining complex concepts simply.",
      "Industry veteran with experience at Microsoft, Amazon, and several startups.",
      "Self-taught programmer turned educator, advocate for accessible online learning.",
      "Data scientist with expertise in Python, R, and statistical analysis.",
      "Web development expert specializing in modern JavaScript frameworks.",
      "Mobile development specialist with apps reaching millions of users."
    ]

    instructor_names.map.with_index do |(first, last, email), idx|
      user = LearnHub::User.find_or_initialize_by(email: email)
      user.assign_attributes(
        first_name: first,
        last_name: last,
        phone: random_phone,
        date_of_birth: Date.today - rand(28..55).years - rand(0..365).days,
        bio: bios[idx % bios.length],
        avatar_url: "https://i.pravatar.cc/150?u=#{email}",
        role: role
      )
      user.save!
      user
    end
  end

  # Students
  def create_students(role)
    puts("Creating students...")

    first_names = [
      'Alex', 'Sam', 'Jordan', 'Taylor', 'Morgan', 'Casey', 'Riley', 'Avery', 'Quinn', 'Blake',
      'Sofia', 'Lucas', 'Emma', 'Oliver', 'Ava', 'Ethan', 'Isabella', 'Mason', 'Mia', 'Noah',
      'Charlotte', 'Liam', 'Amelia', 'William', 'Harper', 'Elijah', 'Evelyn', 'James', 'Abigail',
      'Benjamin', 'Emily', 'Jacob', 'Elizabeth', 'Michael', 'Sofia', 'Alexander', 'Avery',
      'Daniel', 'Ella', 'Matthew', 'Scarlett', 'Henry', 'Grace', 'Joseph', 'Chloe', 'Samuel',
      'Victoria', 'Sebastian', 'Madison', 'David', 'Luna', 'Carter', 'Penelope', 'Wyatt', 'Layla',
      'Jayden', 'Riley', 'John', 'Zoey', 'Owen', 'Nora', 'Dylan', 'Lily', 'Luke', 'Eleanor',
      'Gabriel', 'Hannah', 'Anthony', 'Lillian', 'Isaac', 'Addison', 'Grayson', 'Aubrey', 'Jack',
      'Ellie', 'Julian', 'Stella', 'Levi', 'Natalie', 'Christopher', 'Zoe', 'Joshua', 'Leah',
      'Andrew', 'Hazel', 'Lincoln', 'Violet', 'Mateo', 'Aurora', 'Ryan'
    ]

    last_names = [
      'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez',
      'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor',
      'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez',
      'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright',
      'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores', 'Green', 'Adams', 'Nelson', 'Baker', 'Hall',
      'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts'
    ]

    students = []
    500.times do |i|
      first = first_names.sample
      last = last_names.sample
      email = "#{first.downcase}.#{last.downcase}#{i}@email.com"

      user = LearnHub::User.find_or_initialize_by(email: email)
      user.assign_attributes(
        first_name: first,
        last_name: last,
        phone: rand(2) == 0 ? random_phone : nil,
        date_of_birth: rand(2) == 0 ? (Date.today - rand(16..65).years - rand(0..365).days) : nil,
        bio: rand(3) == 0 ?
               'Passionate learner interested in technology and personal development.' : nil,
        avatar_url: rand(2) == 0 ? "https://i.pravatar.cc/150?u=user#{i}" : nil,
        role: role
      )
      user.save!
      students << user
    end

    puts("Students created/ensured: #{students.count}")
    students
  end

  def create_admin(role)
    admin = LearnHub::User.find_or_initialize_by(email: 'admin@learnhub.com')
    admin.assign_attributes(
      first_name: 'Admin',
      last_name: 'User',
      phone: '+12025550199',
      date_of_birth: Date.today - 35.years,
      bio: 'System administrator',
      role: role
    )
    admin.save!
    admin
  end

  # Categories
  def create_categories
    puts("Creating categories...")
    main_categories = []

    programming = LearnHub::Category.find_or_create_by!(name: 'Programming') do |c|
      c.description = 'Learn various programming languages and concepts'
    end
    main_categories << programming

    %w[Web Development Mobile Development Game Development Data Structures & Algorithms DevOps].each do |name|
      LearnHub::Category.find_or_create_by!(name: name, parent_category: programming) do |c|
        c.description = "Courses related to #{name}"
      end
    end

    data_science = LearnHub::Category.find_or_create_by!(name: 'Data Science') do |c|
      c.description = 'Learn data analysis, machine learning, and AI'
    end
    main_categories << data_science

    %w[Machine Learning Deep Learning Data Analysis Big Data Natural Language Processing].each do |name|
      LearnHub::Category.find_or_create_by!(name: name, parent_category: data_science) do |c|
        c.description = "Courses related to #{name}"
      end
    end

    business = LearnHub::Category.find_or_create_by!(name: 'Business') do |c|
      c.description = 'Business and entrepreneurship courses'
    end
    main_categories << business

    %w[Marketing Finance Management Entrepreneurship Sales].each do |name|
      LearnHub::Category.find_or_create_by!(name: name, parent_category: business) do |c|
        c.description = "Courses related to #{name}"
      end
    end

    design = LearnHub::Category.find_or_create_by!(name: 'Design') do |c|
      c.description = 'Graphic design, UX/UI, and creative courses'
    end
    main_categories << design

    %w[Graphic Design UX/UI Design 3D Design Web Design Motion Graphics].each do |name|
      LearnHub::Category.find_or_create_by!(name: name, parent_category: design) do |c|
        c.description = "Courses related to #{name}"
      end
    end

    personal_dev = LearnHub::Category.find_or_create_by!(name: 'Personal Development') do |c|
      c.description = 'Self-improvement and personal growth'
    end
    main_categories << personal_dev

    %w[Productivity Leadership Communication Time Management Mindfulness].each do |name|
      LearnHub::Category.find_or_create_by!(name: name, parent_category: personal_dev) do |c|
        c.description = "Courses related to #{name}"
      end
    end

    puts("Categories: #{LearnHub::Category.count}")
    LearnHub::Category.all.to_a
  end

  # Courses
  def create_courses(all_categories, instructors)
    puts("Creating courses...")
    templates = build_course_templates
    courses = []

    templates.each_with_index do |template, idx|
      category = all_categories.find { |c| c.name == template[:category_type] }
      unless category
        category = LearnHub::Category.find_or_create_by!(name: template[:category_type]) do |c|
          c.description = "#{template[:category_type]} category"
        end
        all_categories << category
      end

      instructor = instructors.sample

      course = LearnHub::Course.find_or_initialize_by(title: template[:title])
      course.assign_attributes(
        description: template[:description],
        price: template[:price],
        level: template[:level],
        language: template[:language],
        thumbnail_url: "https://picsum.photos/seed/course#{idx}/800/600",
        is_published: rand(10) < 8,
        instructor: instructor,
        category: category,
        created_at: course.created_at || (Date.today - rand(1..730).days)
      )
      course.save!
      courses << course if course.is_published
    end

    puts("Courses ensured: #{LearnHub::Course.count} (published: #{LearnHub::Course.where(is_published: true).count})")
    courses
  end

  # Modules, Lessons, Assignments, Quizzes, Questions, Answers
  def create_modules_and_lessons(courses)
    puts("Creating modules and lessons...")
    module_templates = [
      'Getting Started', 'Fundamentals', 'Intermediate Concepts', 'Advanced Topics', 'Best Practices',
      'Real-World Projects', 'Final Project', 'Bonus Content'
    ]

    lesson_titles = [
      'Introduction', 'Core Concepts', 'Practical Examples', 'Hands-On Practice', 'Deep Dive', 'Case Study',
      'Exercise', 'Review'
    ]

    lesson_types = %w[video text pdf]

    courses.each do |course|
      num_modules = rand(3..6)

      num_modules.times do |mod_idx|
        mod_title = "#{module_templates[mod_idx % module_templates.length]} - #{mod_idx + 1}"
        mod = LearnHub::Module.find_or_create_by!(title: mod_title, course: course) do |m|
          m.description = "This module covers important concepts for mastering #{course.title}"
          m.position = mod_idx + 1
        end

        num_lessons = rand(4..8)
        num_lessons.times do |lesson_idx|
          content_type = lesson_types.sample
          lesson_title = "Lesson #{lesson_idx + 1}: #{lesson_titles.sample}"

          lesson = LearnHub::Lesson.find_or_initialize_by(title: lesson_title, mod: mod)
          lesson.assign_attributes(
            description: "In this lesson, you'll learn key concepts related to #{course.title}",
            content: "This is the main content for this lesson. Students will learn through #{content_type} format.",
            content_type: content_type,
            video_url: content_type == 'video' ?
                         "https://example.com/videos/#{course.id}_#{mod.id}_#{lesson_idx}.mp4" : nil,
            file_url: content_type == 'pdf' ?
                        "https://example.com/files/#{course.id}_#{mod.id}_#{lesson_idx}.pdf" : nil,
            duration_minutes: content_type == 'video' ? rand(10..60) : nil,
            position: lesson_idx + 1,
            is_preview: lesson_idx == 0 && rand(3) == 0
          )
          lesson.save!

          if rand(10) < 3
            LearnHub::Assignment.find_or_create_by!(
              title: "Assignment: #{%w[Build Create Implement Design Develop].sample} a " \
                "#{%w[Project Solution Feature Application System].sample}",
              lesson: lesson
            ) do |a|
              a.description = "Apply what you've learned in this lesson by completing this practical assignment."
              a.max_score = [10, 20, 50, 100].sample
              a.due_date = rand(2) == 0 ? Time.current + rand(7..30).days : nil
            end
          end

          if rand(10) < 4
            quiz = LearnHub::Quiz.find_or_create_by!(title: "Quiz: #{lesson.title}", lesson: lesson) do |q|
              q.description = "Test your understanding of the concepts covered in this lesson"
              q.passing_score = [60, 70, 75, 80].sample
              q.time_limit_minutes = [15, 20, 30, 45].sample
              q.max_attempts = [1, 2, 3, nil].sample
            end

            num_questions = rand(5..10)
            num_questions.times do |q_idx|
              question_type = %w[single_choice multiple_choice text].sample
              question_content = "Question #{q_idx + 1}: What is the main concept of #{lesson.title}?"

              question = LearnHub::Question.find_or_create_by!(content: question_content, quiz: quiz) do |qq|
                qq.question_type = question_type
                qq.points = [1, 2, 5, 10].sample
                qq.explanation = "This question tests your understanding of the core concepts."
              end

              next if question.question_type == 'text'

              num_answers = question.question_type == 'single_choice' ? 4 : rand(4..6)
              num_answers.times do |a_idx|
                answer_content = "Answer option #{a_idx + 1}"
                is_correct = (a_idx == 0) || (question.question_type == 'multiple_choice' && rand(3) == 0)

                LearnHub::Answer.find_or_create_by!(content: answer_content, question: question) do |ans|
                  ans.is_correct = is_correct
                end
              end
            end
          end
        end
      end
    end

    puts("Modules/lessons ensured")
  end

  # Enrollments
  def create_enrollments(courses, students)
    puts("Creating enrollments...")
    courses.each do |course|
      num_enrollments = rand(10..100)
      enrolled_students = students.sample(num_enrollments)

      enrolled_students.each do |student|
        enrolled_at = course.created_at + rand(0..365).days
        status = %w[active active active active completed cancelled].sample
        progress = if status == 'completed'
                     100
                   else
                     status == 'active' ? rand(0..95) : rand(0..50)
                   end
        completed_at = status == 'completed' ? enrolled_at + rand(30..180).days : nil

        enrollment = LearnHub::Enrollment.find_or_create_by!(user: student, course: course) do |e|
          e.enrolled_at = enrolled_at
          e.status = status
          e.progress_percentage = progress
          e.completed_at = completed_at
        end

        # Update fields if enrollment exists but attributes differ
        enrollment.update!(
          enrolled_at: enrollment.enrolled_at || enrolled_at,
          status: enrollment.status || status,
          progress_percentage: enrollment.progress_percentage || progress,
          completed_at: enrollment.completed_at || completed_at
        )
      end
    end

    puts("Enrollments ensured: #{LearnHub::Enrollment.count}")
  end

  # Payments (one payment record per user+course)
  def create_payments
    puts("Creating payments...")
    payment_methods = %w[credit_card paypal stripe bank_transfer]
    payment_statuses = %w[completed completed completed completed pending failed refunded]

    LearnHub::Enrollment.where.not(status: 'cancelled').each do |enrollment|
      next if enrollment.course.price == 0

      status = payment_statuses.sample
      paid_at = enrollment.enrolled_at - rand(0..2).days

      payment = LearnHub::Payment.find_or_create_by!(course: enrollment.course, user: enrollment.user) do |p|
        p.amount = enrollment.course.price
        p.currency = 'USD'
        p.status = status
        p.payment_method = payment_methods.sample
        p.transaction_id = "TXN#{rand(100000..999999)}#{Time.current.to_i}"
        p.paid_at = paid_at
      end

      # Ensure key fields are set (but this will not create duplicates)
      payment.update!(amount: enrollment.course.price, currency: 'USD')
    end

    puts("Payments ensured: #{LearnHub::Payment.count}")
  end

  # Lesson completions
  def create_lesson_completions
    puts("Creating lesson completions...")
    LearnHub::Enrollment.where(status: %w[active completed]).each do |enrollment|
      lessons = enrollment.course.lessons.to_a
      num_completed = (lessons.count * enrollment.progress_percentage / 100.0).round

      lessons.first(num_completed).each do |lesson|
        completed_at = enrollment.enrolled_at + rand(1..90).days
        LearnHub::LessonCompletion.find_or_create_by!(lesson: lesson, user: enrollment.user) do |lc|
          lc.completed_at = completed_at
        end
      end
    end

    puts("Lesson completions ensured: #{LearnHub::LessonCompletion.count}")
  end

  # Reviews
  def create_reviews
    puts("Creating reviews...")
    review_comments = [
      "Excellent course! Very well structured and easy to follow.",
      "Great instructor, explains concepts clearly.",
      "Perfect for beginners. Highly recommend!",
      "Good content but could use more practical examples.",
      "Outstanding course! Worth every penny.",
      "Very comprehensive coverage of the topic.",
      "The instructor is knowledgeable and engaging.",
      "Best course I've taken on this platform.",
      "Content is good but pacing could be better.",
      "Fantastic course! Learned so much."
    ]

    completed_enrollments = LearnHub::Enrollment.where(status: 'completed')
    sample_count = [1, (completed_enrollments.count / 2)].max

    completed_enrollments.sample(sample_count).each do |enrollment|
      review = LearnHub::Review.find_or_create_by!(course: enrollment.course, user: enrollment.user) do |r|
        r.rating = [3, 4, 4, 4, 5, 5, 5, 5].sample
        r.comment = rand(3) == 0 ? review_comments.sample : nil
        r.created_at = enrollment.completed_at + rand(0..7).days
      end

      # If exists, ensure rating/comment are present
      review.update!(rating: review.rating || 5)
    end

    puts("Reviews ensured: #{LearnHub::Review.count}")
  end

  # Certificates
  def create_certificates
    puts("Creating certificates...")
    LearnHub::Enrollment.where(status: 'completed').each do |enrollment|
      certificate_number = "CERT-#{Time.current.year}-#{enrollment.course.id.to_s.rjust(4, '0')}-" \
        "#{enrollment.user.id.to_s.rjust(6, '0')}"

      cert = LearnHub::Certificate.find_or_create_by!(course: enrollment.course, user: enrollment.user) do |c|
        c.certificate_number = certificate_number
        c.issued_at = enrollment.completed_at
        c.certificate_url = "https://certificates.learnhub.com/#{certificate_number}.pdf"
      end

      cert.update!(certificate_number: certificate_number) unless cert.certificate_number == certificate_number
    end

    puts("Certificates ensured: #{LearnHub::Certificate.count}")
  end

  # Discussions + replies
  def create_discussions
    puts("Creating discussions...")
    titles = [
      'Question about lesson 3', 'Stuck on the final project', 'Best practices for this topic?',
      'Alternative approach to this problem', 'Error in the code example', 'Looking for study partners',
      'Additional resources?', 'Real-world applications', 'Clarification needed', 'Great course!'
    ]

    contents = [
      "I'm having trouble understanding this concept. Can someone explain it differently?",
      "Has anyone else encountered this issue? How did you solve it?",
      'I found an alternative way to approach this problem. Thought I\'d share.',
      'Could we get more examples of this in practice?',
      'I think there might be an error in the lecture notes. Can the instructor verify?',
      'Would love to connect with others taking this course!'
    ]

    LearnHub::Enrollment.where(status: %w[active completed]).sample(300).each do |enrollment|
      created_at = enrollment.enrolled_at + rand(5..60).days
      title = titles.sample

      discussion = LearnHub::Discussion.find_or_create_by!(course: enrollment.course, user: enrollment.user, title: title) do |d|
        d.content = contents.sample
        d.views_count = rand(0..500)
        d.is_pinned = rand(50) == 0
        d.created_at = created_at
      end

      num_replies = rand(0..10)
      potential_repliers = enrollment.course.students.where.not(id: enrollment.user.id).to_a
      potential_repliers << enrollment.course.instructor if enrollment.course.instructor

      num_replies.times do
        replier = potential_repliers.sample
        next unless replier

        reply_content = [
          'Thanks for sharing!', 'I had the same question.', "Here's what worked for me...",
          'The instructor covers this in lesson X.'
        ].sample

        LearnHub::DiscussionReply.find_or_create_by!(discussion: discussion, user: replier, content: reply_content) do |rr|
          rr.created_at = discussion.created_at + rand(1..20).hours
        end
      end
    end

    puts("Discussions ensured: #{LearnHub::Discussion.count} with replies: #{LearnHub::DiscussionReply.count}")
  end

  # Submissions
  def create_submissions
    puts("Creating submissions...")
    LearnHub::Assignment.includes(lesson: { mod: :course }).each do |assignment|
      course = assignment.lesson.mod.course
      enrollments = LearnHub::Enrollment.where(course: course, status: %w[active completed])

      num_submissions = (enrollments.count * rand(0.3..0.7)).round
      enrollments.sample(num_submissions).each do |enrollment|
        next unless LearnHub::LessonCompletion.exists?(lesson: assignment.lesson, user: enrollment.user)

        submitted_at = LearnHub::LessonCompletion.find_by(lesson: assignment.lesson, user: enrollment.user).completed_at + rand(1..10).days
        status = %w[pending reviewed graded graded graded].sample
        score = status == 'graded' ? rand(0..assignment.max_score.to_i) : nil
        reviewed_at = %w[reviewed graded].include?(status) ? submitted_at + rand(1..7).days : nil

        submission = LearnHub::Submission.find_or_create_by!(assignment: assignment, user: enrollment.user) do |s|
          s.content = "This is my submission for the assignment. I have completed all requirements."
          s.file_url = rand(2) == 0 ? "https://submissions.learnhub.com/#{assignment.id}_#{enrollment.user.id}.pdf" : nil
          s.score = score
          s.feedback = status == 'graded' ? "Good work! #{['Keep it up!', 'Well done!', 'Nice job!', 'Could improve on...'].sample}" : nil
          s.status = status
          s.submitted_at = submitted_at
          s.reviewed_at = reviewed_at
        end

        submission.update!(status: submission.status || status)
      end
    end

    puts("Submissions ensured: #{LearnHub::Submission.count}")
  end

  # Quiz Attempts & User Answers
  def create_quiz_attempts
    puts("Creating quiz attempts and answers...")

    LearnHub::Quiz.includes(lesson: { mod: :course }).each do |quiz|
      course = quiz.lesson.mod.course
      enrollments = LearnHub::Enrollment.where(course: course, status: %w[active completed])

      num_attempts = (enrollments.count * rand(0.4..0.8)).round
      enrollments.sample(num_attempts).each do |enrollment|
        next unless LearnHub::LessonCompletion.exists?(lesson: quiz.lesson, user: enrollment.user)

        started_at = LearnHub::LessonCompletion.find_by(lesson: quiz.lesson, user: enrollment.user).completed_at + rand(1..30).days
        completed_at = started_at + rand(quiz.time_limit_minutes || 30).minutes
        score = rand(40..100)
        is_passed = score >= quiz.passing_score

        quiz_attempt = LearnHub::QuizAttempt.find_or_create_by!(quiz: quiz, user: enrollment.user) do |qa|
          qa.score = score
          qa.started_at = started_at
          qa.completed_at = completed_at
          qa.is_passed = is_passed
        end

        # Ensure answers: for text — single record; for choices — one per selected answer
        quiz.questions.each do |question|
          if question.question_type == 'text'
            LearnHub::UserAnswer.find_or_create_by!(quiz_attempt: quiz_attempt, question: question) do |ua|
              ua.text_answer = "This is my answer to the question."
              ua.user = enrollment.user
            end
          elsif question.question_type == 'single_choice'
            selected = question.answers.sample
            LearnHub::UserAnswer.find_or_create_by!(quiz_attempt: quiz_attempt, question: question, answer: selected) do |ua|
              ua.user = enrollment.user
            end
          else # multiple_choice
            question.answers.sample(rand(1..3)).each do |answer|
              LearnHub::UserAnswer.find_or_create_by!(quiz_attempt: quiz_attempt, question: question, answer: answer) do |ua|
                ua.user = enrollment.user
              end
            end
          end
        end
      end
    end

    puts("Quiz attempts ensured: #{LearnHub::QuizAttempt.count} with answers: #{LearnHub::UserAnswer.count}")
  end

  # Summary
  def print_summary
    puts("")
    puts("=" * 60)
    puts("Database Summary:")
    puts("-" * 60)

    puts("Roles:                 #{LearnHub::Role.count}")
    puts("Users:                 #{LearnHub::User.count}")
    puts("  - Instructors:       #{LearnHub::User.joins(:role).where(roles: {name: 'instructor'}).count}")
    puts("  - Students:          #{LearnHub::User.joins(:role).where(roles: {name: 'student'}).count}")
    puts("  - Admins:            #{LearnHub::User.joins(:role).where(roles: {name: 'admin'}).count}")
    puts("Categories:            #{LearnHub::Category.count}")
    puts("Courses:               #{LearnHub::Course.count}")
    puts("  - Published:         #{LearnHub::Course.where(is_published: true).count}")
    puts("  - Free:              #{LearnHub::Course.where(price: 0).count}")
    puts("Modules:               #{LearnHub::Module.count}")
    puts("Lessons:               #{LearnHub::Lesson.count}")
    puts("Assignments:           #{LearnHub::Assignment.count}")
    puts("Quizzes:               #{LearnHub::Quiz.count}")
    puts("Questions:             #{LearnHub::Question.count}")
    puts("Answers:               #{LearnHub::Answer.count}")
    puts("Enrollments:           #{LearnHub::Enrollment.count}")
    puts("  - Active:            #{LearnHub::Enrollment.where(status: 'active').count}")
    puts("  - Completed:         #{LearnHub::Enrollment.where(status: 'completed').count}")
    puts("Payments:              #{LearnHub::Payment.count}")
    puts("Lesson Completions:    #{LearnHub::LessonCompletion.count}")
    puts("Reviews:               #{LearnHub::Review.count}")
    puts("Certificates:          #{LearnHub::Certificate.count}")
    puts("Discussions:           #{LearnHub::Discussion.count}")
    puts("Discussion Replies:    #{LearnHub::DiscussionReply.count}")
    puts("Submissions:           #{LearnHub::Submission.count}")
    puts("Quiz Attempts:         #{LearnHub::QuizAttempt.count}")
    puts("User Answers:          #{LearnHub::UserAnswer.count}")
    puts("-" * 60)
    puts("Your database is ready for SQL practice!")
    puts("=" * 60)
  end

  # Helpers
  def random_phone
    "+1#{rand(200..999)}#{rand(200..999)}#{rand(1000..9999)}"
  end

  def build_course_templates
    [
      # Programming courses
      {title: 'Complete Python Bootcamp', level: 'beginner', price: 89.99, language: 'en',
       category_type: 'Web Development',
       description: 'Learn Python programming from scratch. Cover basics, OOP, web development with Django, and data analysis.'},
      {title: 'Advanced JavaScript and React', level: 'advanced', price: 129.99, language: 'en',
       category_type: 'Web Development',
       description: 'Master modern JavaScript ES6+ and React framework. Build complex single-page applications.'},
      {title: 'Ruby on Rails Masterclass', level: 'intermediate', price: 99.99, language: 'en',
       category_type: 'Web Development',
       description: 'Build web applications with Ruby on Rails. Learn MVC architecture, authentication, and deployment.'},
      {title: 'iOS Development with Swift', level: 'intermediate', price: 109.99, language: 'en',
       category_type: 'Mobile Development',
       description: 'Create iOS apps from scratch. Learn Swift programming, UIKit, and app store deployment.'},
      {title: 'Android Development Fundamentals', level: 'beginner', price: 79.99, language: 'en',
       category_type: 'Mobile Development',
       description: 'Start building Android apps with Kotlin. Cover activities, fragments, and material design.'},
      {title: 'Unity Game Development', level: 'beginner', price: 94.99, language: 'en',
       category_type: 'Game Development',
       description: 'Create 2D and 3D games with Unity engine. Learn C# scripting and game physics.'},
      {title: 'Data Structures and Algorithms in Java', level: 'intermediate', price: 84.99, language: 'en',
       category_type: 'Data Structures & Algorithms',
       description: 'Master essential data structures and algorithms. Prepare for technical interviews.'},
      {title: 'Docker and Kubernetes for Beginners', level: 'beginner', price: 69.99, language: 'en',
       category_type: 'DevOps', description: 'Learn containerization with Docker and orchestration with Kubernetes.'},

      # Data Science courses
      {title: 'Machine Learning A-Z', level: 'intermediate', price: 119.99, language: 'en',
       category_type: 'Machine Learning',
       description: 'Comprehensive guide to machine learning algorithms. Python, scikit-learn, and real projects.'},
      {title: 'Deep Learning Specialization', level: 'advanced', price: 149.99, language: 'en',
       category_type: 'Deep Learning',
       description: 'Neural networks, CNNs, RNNs, and transformers. TensorFlow and PyTorch implementations.'},
      {title: 'Data Analysis with Python', level: 'beginner', price: 74.99, language: 'en',
       category_type: 'Data Analysis',
       description: 'Pandas, NumPy, and Matplotlib for data manipulation and visualization.'},
      {title: 'Apache Spark for Big Data', level: 'advanced', price: 139.99, language: 'en',
       category_type: 'Big Data',
       description: 'Process large datasets with Apache Spark. Learn PySpark and Spark SQL.'},
      {title: 'Natural Language Processing with Python', level: 'intermediate', price: 109.99, language: 'en',
       category_type: 'Natural Language Processing',
       description: 'Text processing, sentiment analysis, and language models. NLTK and spaCy.'},

      # Business courses
      {title: 'Digital Marketing Masterclass', level: 'beginner', price: 79.99, language: 'en',
       category_type: 'Marketing',
       description: 'SEO, social media, email marketing, and Google Analytics. Complete digital strategy.'},
      {title: 'Financial Analysis and Valuation', level: 'intermediate', price: 99.99, language: 'en',
       category_type: 'Finance',
       description: 'Learn financial modeling, DCF analysis, and company valuation techniques.'},
      {title: 'Project Management Professional', level: 'intermediate', price: 89.99, language: 'en',
       category_type: 'Management',
       description: 'PMP certification prep. Agile, Scrum, and traditional project management.'},
      {title: 'Startup Essentials', level: 'beginner', price: 59.99, language: 'en',
       category_type: 'Entrepreneurship',
       description: 'Launch your startup. Business planning, funding, and growth strategies.'},
      {title: 'Sales Mastery Course', level: 'beginner', price: 69.99, language: 'en',
       category_type: 'Sales', description: 'Modern sales techniques, negotiation, and closing deals effectively.'},

      # Design courses
      {title: 'Graphic Design Fundamentals', level: 'beginner', price: 64.99, language: 'en',
       category_type: 'Graphic Design',
       description: 'Typography, color theory, composition. Master Adobe Photoshop and Illustrator.'},
      {title: 'UX/UI Design Bootcamp', level: 'intermediate', price: 94.99, language: 'en',
       category_type: 'UX/UI Design', description: 'User research, wireframing, prototyping. Figma and Adobe XD.'},
      {title: 'Blender 3D Complete Course', level: 'beginner', price: 79.99, language: 'en',
       category_type: '3D Design', description: 'Create stunning 3D models and animations with Blender.'},
      {title: 'Responsive Web Design', level: 'beginner', price: 54.99, language: 'en',
       category_type: 'Web Design', description: 'HTML, CSS, and responsive design principles. Build beautiful websites.'},
      {title: 'After Effects Motion Graphics', level: 'intermediate', price: 89.99, language: 'en',
       category_type: 'Motion Graphics', description: 'Create professional animations and visual effects with After Effects.'},

      # Personal Development
      {title: 'Productivity Masterclass', level: 'beginner', price: 49.99, language: 'en',
       category_type: 'Productivity', description: 'Time management, goal setting, and productivity systems that work.'},
      {title: 'Leadership and Team Management', level: 'intermediate', price: 74.99, language: 'en',
       category_type: 'Leadership', description: 'Develop leadership skills, emotional intelligence, and team building.'},
      {title: 'Effective Communication Skills', level: 'beginner', price: 44.99, language: 'en',
       category_type: 'Communication', description: 'Public speaking, presentation skills, and interpersonal communication.'},
      {title: 'Time Management Mastery', level: 'beginner', price: 39.99, language: 'en',
       category_type: 'Time Management', description: 'Prioritization techniques, calendar management, and work-life balance.'},
      {title: 'Mindfulness and Meditation', level: 'beginner', price: 34.99, language: 'en',
       category_type: 'Mindfulness', description: 'Stress reduction through mindfulness practice and meditation techniques.'},

      # Additional programming courses
      {title: 'Go Programming Language', level: 'intermediate', price: 79.99, language: 'en',
       category_type: 'Web Development', description: 'Learn Go for building scalable backend services and microservices.'},
      {title: 'Vue.js Complete Guide', level: 'intermediate', price: 84.99, language: 'en',
       category_type: 'Web Development', description: 'Build reactive web applications with Vue.js framework and Vuex.'},
      {title: 'SQL and Database Design', level: 'beginner', price: 59.99, language: 'en',
       category_type: 'Web Development', description: 'Master SQL queries, database design, and optimization techniques.'},
      {title: 'Flutter Mobile Development', level: 'intermediate', price: 94.99, language: 'en',
       category_type: 'Mobile Development', description: 'Build cross-platform mobile apps with Flutter and Dart.'},
      {title: 'Rust Programming Fundamentals', level: 'advanced', price: 99.99, language: 'en',
       category_type: 'Programming', description: 'Systems programming with Rust. Memory safety and concurrency.'},

      # More Data Science
      {title: 'Statistics for Data Science', level: 'beginner', price: 64.99, language: 'en',
       category_type: 'Data Analysis', description: 'Statistical concepts essential for data science and machine learning.'},
      {title: 'Computer Vision with OpenCV', level: 'advanced', price: 124.99, language: 'en',
       category_type: 'Deep Learning', description: 'Image processing, object detection, and facial recognition with OpenCV.'},
      {title: 'Time Series Analysis', level: 'intermediate', price: 89.99, language: 'en',
       category_type: 'Data Analysis', description: 'Forecasting and analyzing time series data with Python.'},

      # Additional Business
      {title: 'Content Marketing Strategy', level: 'intermediate', price: 69.99, language: 'en',
       category_type: 'Marketing', description: 'Create compelling content strategies that drive traffic and conversions.'},
      {title: 'Product Management Fundamentals', level: 'beginner', price: 79.99, language: 'en',
       category_type: 'Management', description: 'Product lifecycle, roadmapping, and stakeholder management.'},
      {title: 'Business Analytics with Excel', level: 'beginner', price: 54.99, language: 'en',
       category_type: 'Finance', description: 'Advanced Excel techniques for business analysis and reporting.'},

      # Free courses
      {title: 'Introduction to Programming', level: 'beginner', price: 0, language: 'en',
       category_type: 'Programming', description: 'Free introduction to programming concepts and problem-solving.'},
      {title: 'HTML and CSS Basics', level: 'beginner', price: 0, language: 'en',
       category_type: 'Web Development', description: 'Start your web development journey with HTML and CSS basics.'},
      {title: 'Git and GitHub Essentials', level: 'beginner', price: 0, language: 'en',
       category_type: 'DevOps', description: 'Version control fundamentals for developers.'},
      {title: 'Personal Branding Basics', level: 'beginner', price: 0, language: 'en',
       category_type: 'Marketing', description: 'Build your personal brand on social media and professional networks.'},
      {title: 'Introduction to Data Science', level: 'beginner', price: 0, language: 'en',
       category_type: 'Data Science', description: 'Free introduction to data science concepts and tools.'}
    ]
  end
end

LearnHubSeeds.run
