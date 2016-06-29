require 'common'

#
# This is a spec file to test functionality of the deep-hash rspecs.
# It does not test actual Uliska output data.
# ===================================================================
describe '"Normalized" Hash' do

  before(:each) do
    #
    # TEST DATA: Good normalized hash for use in tests
    # ================================================
    @hash = { 
      :symbol => { :str => 'str',  :num => 42,  :arr => [1,2,3]  }, # single symbol key
      :string => { 'str' => 'str', 'num' => 42, 'arr' => [1,2,3] }, # single string key
      :sym_str => { 
        :a => 1, :aa => 'a',
        'b' => 2, 'bb' => 'bb'
      },
      :l2 => {  # level 2 hash
        :aa => 1,  
        :bb => { :bbb => [1,2,3], 'ccc' => "string", :ddd => 42 }, # symbol and string keys
        'cc' => 3 
      },
      :b => { 
        :ba => 1, 
        :bb => 2, 
        'bc' => { :caa => 1, :cbb => 'asdfas', 'dd' => 'file'}, 
        'abc' => 'a' 
      },
      :n_array => [1,2,3,4],
      :s_array => ["a","b","c"],
      :mix_array => [1, "a", {} ],
      :array_hash => 
      [
       { :name =>'a' },
       { :name =>'b' },
       { :name =>'c' },
      ],

      :names => 
      [
       { :name =>'a' },
       { :name =>'b' },
       { :name =>'c' },
      ],

      :people => 
      [
       { :person =>'a' },
       { :person =>'b' },
       { :person =>'c' },
      ]


    }
  end
  # ============================================================
  @enclosed_hash = { 
    :simple => [
                { },
                { },
                { },
               ],
    :nested => { 
      :level2 => [
                  { },
                  { },
                  { },
                 ]
    }
    
  }
  
  # ============================================================


  # ------------------------------------------------------------
  context 'Hash keys and values' do
    context "simple hash" do
      
      context "single Symbol key" do
        subject { @hash[:symbol] }

        it { should      have_keys_in_class Symbol }
        it { should_not  have_keys_in_class String }

        it { should      have_values_in_class [String, Numeric, Array, Hash] }
        it { should_not  have_values_in_class IO }

        it { should  have_array_values_in_class [Numeric, String, Hash] }

      end
      
      context "single String key" do
        subject { @hash[:string] }

        it { should      have_keys_in_class String }
        it { should_not  have_keys_in_class Symbol }

        it { should      have_values_in_class [String, Numeric, Array, Hash] }
        it { should_not  have_values_in_class IO }
      end
      
      context "Symbol and String keys" do
        subject { @hash[:sym_str] }
        
        it { should     have_keys_in_class [Symbol, String] }
        it { should     have_keys_in_class [Symbol, String, File] }
        it { should_not have_keys_in_class [Symbol, File] }
        it { should_not have_keys_in_class Symbol }
        it { should_not have_keys_in_class String }
      end

      context "nested Hash" do
        
        context "2 levels" do
          subject { @hash[:l2] }
          it { should                                  have_keys_in_class [Symbol, String] }
          it { subject.merge({[1,2] => 1 }).should_not have_keys_in_class [Symbol, String] }

          it { should      have_values_in_class [String, Numeric, Array, Hash] }
          it { should_not  have_values_in_class IO }

        end
        
        context "3 levels" do
          subject {  @hash }
          it { should have_keys_in_class [Symbol, String] }


          it {
            bad = { :a => { :b => { :bbb => [1,2,3], 'ccc' => "string", 42 => 42 }}}
            bad.should_not  have_keys_in_class [Symbol, String]
          }

          it { should      have_values_in_class [String, Numeric, Array, Hash] }
          
          it {
            subject.merge(
                          { :file => File.new('a','w') }
                          ).should_not have_values_in_class [String, Numeric, Array, Hash]
          }
        end # 3 levels
      end # nested Hash
    end # Hash  


  end # context 'Hash keys and values' do

  # ------------------------------------------------------------
  context "Array values" do

    context "simple" do
      context "Numeric array" do 
        subject { @hash[:n_array] }
        it { should have_array_values_in_class Numeric }
        it { should have_array_values_of_the_same_class }
        it "with different values should not have same class" do 
          subject << 'a'
          should_not have_array_values_of_the_same_class
        end
      end
      
      context "String array" do 
        subject { @hash[:s_array] }
        it { should have_array_values_in_class String }
      end

      context "mixed array" do 
        subject { @hash[:mix_array] }
        it { should     have_array_values_in_class [String,Numeric,Hash] }
        it { should_not have_array_values_in_class IO }
      end

      context "array of Hash'es" do
        subject { @hash[:array_hash] }
        it { should     have_array_values_in_class [String,Numeric,Hash] }
        it { should_not have_array_values_in_class IO }
      end
    end

    context "multi level" do 
      subject { @hash }
      it { should     have_array_values_in_class [String,Numeric,Hash] }
      it { should_not have_array_values_in_class IO }
      it { should_not have_array_values_of_the_same_class }
      it "when removed mixed array should all be in the same class" do 
        subject.delete :mix_array
        should have_array_values_of_the_same_class
      end
    end
  end # context "Array values" do
  # ------------------------------------------------------------
  context "Hash enclosed in Array " do 
    context "Hash-> Array-> [Hash]" do 
      context :simple do 
        subject {  @hash[:names] }
        it { should have_all_keys_be_word_name_or_singular_of :names }
        it { @hash[:people].should have_all_keys_be_word_name_or_singular_of :people}

        it { should_not have_all_keys_be_word_name_or_singular_of :last_names }
        it { @hash[:people].should have_all_keys_be_word_name_or_singular_of :people}
      end

      context :simple_changed do 
        subject {  @hash[:names] << { :not_really_name => 'some string', :name => 'name' } }
        it { should have_all_keys_be_word_name_or_singular_of :names }
        it { should_not have_all_keys_be_word_name_or_singular_of :last_names }
      end
    end # context "keys of Hash enclosed in an Array" do 

    context "Hash-> [Array]-> Hash " do
      context "one level" do
        subject { {:people => @hash[:people]} }
        it { should all_arrays_have_hash_with_key_word_name_or_singular_of_hash_key }
      end

      context '2 levels' do 
        subject { 
           { 
          #:single_levels => [
#                         { :single_level => 1},
#                         { :single_level => 2},
#                        ],
            :deep => 
            { :two_levelsess => 
              [
               { :name => :one},
               { :name => :two},
              ]
            }
          }
        }
        it { should all_arrays_have_hash_with_key_word_name_or_singular_of_hash_key }
      end
    end # context "Hash-> [Array]-> Hash" do 
  end #  context "enclosed in Array Hash" do 
end
